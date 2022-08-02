#!/usr/bin/env python3
import psycopg2

#####################################################
##  Database Connection
#####################################################

'''
Connect to the database using the connection string
'''
def openConnection():
    # connection parameters - ENTER YOUR LOGIN AND PASSWORD HERE
    userid = "your database userid"
    passwd = "your database password"
    myHost = "your database url/path"

    # Create a connection to the database
    conn = None
    try:
        # Parses the config file and connects using the connect string
        conn = psycopg2.connect(database=userid,
                                    user=userid,
                                    password=passwd,
                                    host=myHost)
    except psycopg2.Error as sqle:
        print("psycopg2.Error : " + sqle.pgerror)
    
    # return the connection to use
    return conn

#####################################################
##  Olympics Booking System
#####################################################

'''
Validate user login request based on username and password
'''
def checkUserCredentials(usern, passw):    
    if usern == "-":
        return None
    try:  
        conn = openConnection()
        curs = conn.cursor()
        curs.callproc("checkUserCredentials", (usern, passw))
        userInfo = curs.fetchone()
        curs.close()
        conn.close()
    except psycopg2.Error:
        userInfo = None    
    return userInfo


'''
List all the associated events in the database for a given official
'''
def findEventsByOfficial(official_id):    
    try:
        conn = openConnection()
        curs = conn.cursor()        
        curs.callproc("findEventsByOfficial", (official_id,))        
        event_list = [{
            'event_id': str(row[0]),
            'event_name': row[1],
            'sport': row[2],
            'referee': row[3],
            'judge': row[4],
            'medal_giver': row[5]
        } for row in curs]
        curs.close()
        conn.close()
    except psycopg2.Error:
        event_list = None
    return event_list


'''
Find a list of events based on the searchString provided as parameter
See assignment description for search specification
'''
def findEventsByCriteria(searchString):
    try:
        conn = openConnection()
        curs = conn.cursor()
        curs.callproc("findEventsByCriteria", (searchString,))
        event_list = [{
            'event_id': str(row[0]),
            'event_name': row[1],
            'sport': row[2],
            'referee': row[3],
            'judge': row[4],
            'medal_giver': row[5]
        } for row in curs]
        curs.close()
        conn.close()
    except psycopg2.Error:
        event_list = None
    return event_list


'''
Add a new event
'''
def addEvent(event_name, sport, referee, judge, medal_giver):
    try:
        conn = openConnection()
        curs = conn.cursor()

        # Step 1: check event name is provided and not yet in database
        validEventName = True
        if (event_name == None):
            validEventName = False
        else:
            curs.execute(
                "SELECT eventId FROM Event WHERE UPPER(eventName)=UPPER(%s)", (event_name,))
            event_id = curs.fetchone()

            if (event_id != None):
                validEventName = False

        # Step 2: check all other inputs provided and valid.
        validInput = ValidateEvent(curs=curs, sport=sport, referee=referee, 
                                   judge=judge, medal_giver=medal_giver)

        # Step 1 & 2 both ok?
        validAllInput = validEventName and validInput.isValid

        # add event
        if validAllInput:
            curs.callproc("addEvent", (event_name, validInput.sport_id, 
                                       validInput.referee_id, validInput.judge_id, 
                                       validInput.medal_giver_id, ))
            conn.commit()

        curs.close()
        conn.close()

    except AttributeError:
        validAllInput = False

    return validAllInput


'''
Update an existing event
'''
def updateEvent(event_id, event_name, sport, referee, judge, medal_giver):
    try:
        conn = openConnection()
        curs = conn.cursor()

        # Step 1: check event name is not none, any string is OK.
        validEventName = (event_name != None)

        # Step 2: check all other inputs provided and valid.
        validInput = ValidateEvent(curs=curs, sport=sport, referee=referee, 
                                   judge=judge, medal_giver=medal_giver)

        # Step 1 & 2 both ok?
        validAllInput = validEventName and validInput.isValid

        # update event
        if validAllInput:
            curs.callproc("updateEvent", (event_id, event_name, validInput.sport_id, 
                                          validInput.referee_id, validInput.judge_id, 
                                          validInput.medal_giver_id,))
            conn.commit()

        curs.close()
        conn.close()

    except AttributeError:
        validAllInput = False

    return validAllInput


'''
Validates sport/official names are (not None and) valid, returns sport/official ids and a status.
'''

class ValidateEvent():
    def __init__(self, curs, sport, referee, judge, medal_giver):
        # This is an optimistic class.
        self.isValid = True

        for arg in (sport, referee, judge, medal_giver):
            if arg == None:
                print("Not enough input.")
                self.isValid = False

        # find sport in database
        curs.execute(
            "SELECT sportID FROM Sport WHERE UPPER(sportName)=UPPER(%s)", (sport, ))
        row = curs.fetchone()
        self.sport_id = None
        while row is not None:
            self.sport_id = int(row[0])
            break

        # find referee in database
        self.referee_id =  int(officialIdFromUsername(curs=curs, searchName=referee)[0])

        # find judge in database
        self.judge_id =  int(officialIdFromUsername(curs=curs, searchName=judge)[0])

        # find medal_giver in database
        self.medal_giver_id = int(officialIdFromUsername(curs=curs, searchName=medal_giver)[0])

        # if sport or any official not found in DB:
        for id in (self.sport_id, self.referee_id, self.judge_id, self.medal_giver_id):
            if id == None:
                self.isValid = False


'''
Get official ID from username, or None if not found.
'''

def officialIdFromUsername(curs, searchName):
    id = None
    curs.execute("SELECT officialID FROM Official WHERE UPPER(username)=UPPER(%s)", (searchName,))
    id = curs.fetchone()
    return id