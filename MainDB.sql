CREATE TABLE Person
(
    PR_ID          SERIAL       NOT NULL,
    PR_Name        VARCHAR(100) NOT NULL,
    PR_HomeCountry VARCHAR(2)   NOT NULL,
    PR_Email       VARCHAR(100) NOT NULL UNIQUE,
    PR_Gender      VARCHAR(1)   NOT NULL,
    PR_DateOfBirth DATE         NOT NULL,

    CONSTRAINT Person_PK PRIMARY KEY (PR_ID),
    CONSTRAINT Person_Gender_CHK CHECK (PR_Gender IN ('M', 'F'))
);

INSERT INTO Person (PR_ID, PR_Name, PR_HomeCountry, PR_Email, PR_Gender, PR_DateOfBirth)
VALUES (1, 'John Doe', 'AU', 'john.doe@sports.com.au', 'M', '01/01/2000'),
       (2, 'Jane Doe', 'US', 'jane.doe@sports.com', 'F', '04/07/1999');

CREATE TABLE Athlete
(
    AT_ID           SERIAL     NOT NULL,
    AT_Person       INTEGER    NOT NULL  UNIQUE,
    AT_BirthCountry VARCHAR(2) NOT NULL,

    CONSTRAINT Athlete_PK PRIMARY KEY (AT_ID),
    CONSTRAINT Athlete_Person_FK FOREIGN KEY (AT_Person) REFERENCES Person (PR_ID) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
);

	
INSERT INTO Athlete (AT_ID, AT_Person, AT_BirthCountry)
VALUES (1, 1, 'JP');

CREATE TABLE Official
(
    OF_ID     SERIAL      NOT NULL,
    OF_Person INTEGER     NOT NULL  UNIQUE,
    OF_Role   VARCHAR(50) NOT NULL,

    CONSTRAINT Official_PK PRIMARY KEY (OF_ID),
    CONSTRAINT Official_Person_FK FOREIGN KEY (OF_Person) REFERENCES Person (PR_ID) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT Official_Role_CHK CHECK (OF_Role IN ('REFEREE', 'JUDGE', 'CEREMONIAL'))
);

INSERT INTO Official (OF_ID, OF_Person, OF_Role)
VALUES (1, 2, 'REFEREE');

CREATE TABLE Event
(
    EV_ID         SERIAL                   NOT NULL,
    EV_Name       VARCHAR(100)             NOT NULL  UNIQUE,
    EV_Sport      VARCHAR(100)             NOT NULL,
    EV_Run        TIMESTAMP WITH TIME ZONE NOT NULL,
    EV_ResultType VARCHAR(2)               NOT NULL,

    CONSTRAINT Event_PK PRIMARY KEY (EV_ID),
    CONSTRAINT Event_ResultType_CHK CHECK (EV_ResultType IN ('SC', 'PT'))
);

INSERT INTO Event (EV_ID, EV_Name, EV_Sport, EV_Run, EV_ResultType)
VALUES (1, 'Men''s High Jump', 'High Jump', '07/10/2032 10:30am', 'PT');

CREATE TABLE Participates
(
    PA_ID      SERIAL      NOT NULL,
    PA_Athlete INTEGER     NOT NULL,
    PA_Event   INTEGER     NOT NULL,
    PA_Result  VARCHAR(50) NOT NULL,

    CONSTRAINT Participant_PK PRIMARY KEY (PA_ID),
    CONSTRAINT Participant_Athlete_FK FOREIGN KEY (PA_Athlete) REFERENCES Athlete (AT_ID) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT Participant_Event_FK FOREIGN KEY (PA_Event) REFERENCES Event (EV_ID) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
);

INSERT INTO Participates (PA_ID, PA_Athlete, PA_Event, PA_Result)
VALUES (1, 1, 1, '10m');

CREATE TABLE Officiates
(
    OI_ID       SERIAL  NOT NULL,
    OI_Official INTEGER NOT NULL,
    OI_Event    INTEGER NOT NULL,

    CONSTRAINT Officiates_PK PRIMARY KEY (OI_ID),
    CONSTRAINT Officiates_Official_FK FOREIGN KEY (OI_Official) REFERENCES Official (OF_ID) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT Officiates_Event_FK FOREIGN KEY (OI_Event) REFERENCES Event (EV_ID) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
);

INSERT INTO Officiates (OI_ID, OI_Official, OI_Event)
VALUES (1, 1, 1);

CREATE TABLE Vehicle
(
    VE_ID       SERIAL      NOT NULL,
    VE_Rego     VARCHAR(6)  NOT NULL UNIQUE,     
    VE_Capacity INTEGER     NOT NULL,
    VE_Type     VARCHAR(50) NOT NULL,

    CONSTRAINT Vehicle_PK PRIMARY KEY (VE_ID),
    CONSTRAINT Vehicle_Type_CHK CHECK (VE_Type IN ('BUS', 'MIN', 'VAN')),
    CONSTRAINT Vehicle_Capacity_CHK CHECK (VE_Capacity > 0 AND VE_Capacity < 24)
);

INSERT INTO Vehicle (VE_ID, VE_Rego, VE_Capacity, VE_Type)
VALUES (1, 'ABC123', 8, 'MIN');

CREATE TABLE Location
(
    LO_ID               SERIAL         NOT NULL,
    LO_Name             VARCHAR(100)   NOT NULL  UNIQUE,
    LO_BuildDate        DATE           NOT NULL,
    LO_BuildCost        MONEY          NOT NULL,
    LO_GPS_Latitude     DECIMAL(10, 8) NOT NULL,
    LO_GPS_Longitude    DECIMAL(11, 8) NOT NULL,
    LO_Address_Line1    VARCHAR(100)   NOT NULL,
    LO_Address_Line2    VARCHAR(100)   NOT NULL,
    LO_Address_Suburb   VARCHAR(50)    NOT NULL,
    LO_Address_Postcode VARCHAR(4)     NOT NULL,
    LO_Address_Region   VARCHAR(50)    NOT NULL,

    CONSTRAINT Location_PK PRIMARY KEY (LO_ID),
    CONSTRAINT Location_BuildCost_CHK CHECK (CAST(LO_BuildCost AS numeric) > 0),
    CONSTRAINT Location_Latitude_CHK CHECK (LO_GPS_Latitude >= -90 AND LO_GPS_Latitude <= 90),
    CONSTRAINT Location_Longitude_CHK CHECK (LO_GPS_Longitude >= -180 AND LO_GPS_Longitude <= 180)
);

INSERT INTO Location (LO_ID, LO_Name, LO_BuildDate, LO_BuildCost, LO_GPS_Longitude, LO_GPS_Latitude,
                      LO_Address_Line1, LO_Address_Line2, LO_Address_Suburb, LO_Address_Postcode, LO_Address_Region)
VALUES (1, 'Main Stadium', '15/01/2030', '$150000000', -59.40475, 17.06167, 'Vulture St', '', 'Woolloongabba', '4120',
        'South Bank'),
       (2, 'Main Village', '23/02/2029', '$50000000', -40.19559, -54.09665, '332 Old Cleveland Rd', '', 'Coorparoo',
        '4151', 'Wembly Park');

CREATE TABLE Village
(
    VI_ID       SERIAL  NOT NULL,
    VI_Location INTEGER NOT NULL UNIQUE,
    VI_Capacity INTEGER NOT NULL,

    CONSTRAINT Village_PK PRIMARY KEY (VI_ID),
    CONSTRAINT Village_Location_FK FOREIGN KEY (VI_Location) REFERENCES Location (LO_ID) DEFERRABLE INITIALLY DEFERRED
);

INSERT INTO Village (VI_ID, VI_Location, VI_Capacity)
VALUES (1, 2, 10);

CREATE TABLE Venue
(
    VU_ID       SERIAL      NOT NULL,
    VU_Location INTEGER     NOT NULL UNIQUE,
    VU_Type     VARCHAR(50) NOT NULL,

    CONSTRAINT Venue_PK PRIMARY KEY (VU_ID),
    CONSTRAINT Venue_Location_FK FOREIGN KEY (VU_Location) REFERENCES Location (LO_ID) DEFERRABLE INITIALLY DEFERRED
);

INSERT INTO Venue (VU_ID, VU_Location, VU_Type) VALUES (1, 1, 'Stadium');

CREATE TABLE Hosts
(
    HO_ID    SERIAL  NOT NULL,
    HO_Venue INTEGER NOT NULL,
    HO_Event INTEGER NOT NULL,

    CONSTRAINT Hosts_PK PRIMARY KEY (HO_ID),
    CONSTRAINT Hosts_Location_FK FOREIGN KEY (HO_Venue) REFERENCES Venue (VU_ID) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT Hosts_Event_FK FOREIGN KEY (HO_Event) REFERENCES Event (EV_ID) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
);

INSERT INTO Hosts (HO_ID, HO_Venue, HO_Event)
VALUES (1, 1, 1);

CREATE TABLE LivesIn
(
    LI_ID      SERIAL  NOT NULL,
    LI_Village INTEGER NOT NULL,
    LI_Person  INTEGER NOT NULL,

    CONSTRAINT LivesIn_PK PRIMARY KEY (LI_ID),
    CONSTRAINT LivesIn_Location_FK FOREIGN KEY (LI_Village) REFERENCES Village (VI_ID) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT LivesIn_Person_FK FOREIGN KEY (LI_Person) REFERENCES Person (PR_ID) ON DELETE CASCADE DEFERRABLE INITIALLY DEFERRED
);

INSERT INTO LivesIn (LI_ID, LI_Village, LI_Person)
VALUES (1, 1, 1);

CREATE TABLE Trip
(
    TR_ID             SERIAL  NOT NULL,
    TR_LO_Origin      INTEGER NOT NULL,
    TR_LO_Destination INTEGER NOT NULL,
    TR_Vehicle        INTEGER NOT NULL,
    TR_Departure      TIMESTAMP WITH TIME ZONE,
    TR_Arrival         TIMESTAMP WITH TIME ZONE,

    CONSTRAINT Trip_PK PRIMARY KEY (TR_ID),
    CONSTRAINT Trip_Location_Origin_FK FOREIGN KEY (TR_LO_Origin) REFERENCES Location (LO_ID) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT Trip_Location_Destination_FK FOREIGN KEY (TR_LO_Destination) REFERENCES Location (LO_ID) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT Trip_Vehicle_FK FOREIGN KEY (TR_Vehicle) REFERENCES Vehicle (VE_ID) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT Trip_Date_Validation_CHK CHECK (TR_Arrival > TR_Departure)
);

INSERT INTO Trip (TR_ID, TR_LO_Origin, TR_LO_Destination, TR_Vehicle, TR_Departure, TR_Arrival)
VALUES (1, 1, 2, 1, '04/08/2023 12:00pm', '04/08/2023 1:30pm');

CREATE TABLE Booking
(
    BK_ID     SERIAL  NOT NULL,
    BK_Trip   INTEGER NOT NULL,
    BK_Person INTEGER NOT NULL,

    CONSTRAINT Booking_PK PRIMARY KEY (BK_ID),
    CONSTRAINT Booking_Trip_FK FOREIGN KEY (BK_Trip) REFERENCES Trip (TR_ID) DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT Booking_Person_FK FOREIGN KEY (BK_Person) REFERENCES Person (PR_ID) DEFERRABLE INITIALLY DEFERRED
);

INSERT INTO Booking (BK_ID, BK_Trip, BK_Person) VALUES (1, 1, 2);
