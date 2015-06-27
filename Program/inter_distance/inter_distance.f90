!     Last change:  123  30 Jun 2005    1:38 pm
!     DR. VO VAN HOANG
!     DEPARTMENT OF PHYSICS, NATIONAL UNIVERSITY OF HOCHIMINH CITY-VIETNAM
!
!     PROGRAM CALCULATING THE INTERATOMIC DISTANCE DISTRIBUTION
!     FOR 2D SYSTEM
!     
    IMPLICIT NONE
	! Define constant
	INTEGER, PARAMETER :: ATOM1 = 1, ATOM2 = 2, MAX = 900000, SINGLE = 1, BINARY_COMPOUND = 2, ACCURACY = 100
	! Cutoff
    REAL RC
	! Temporary coordinate
	REAL tempX, tempY, tempZ
	! Coordinate of each atom
	REAL, DIMENSION(MAX) :: x1, y1, z1, x2, y2, z2
	! INTERATOMIC DISTANCE 
	INTEGER, DIMENSION(MAX) :: distance12, distance21
	! Number of atom
	INTEGER :: typeAtom = 0, cntAtom1 = 0, cntAtom2 = 0, totalAtom = 0, substanceType = 0
	! Loop variable
	INTEGER i, j, count
	!*********************************************************
	! Ask for user choice
	PRINT *, 'Choose your substance type: '
	PRINT *, SINGLE, ': SINGLE'
	PRINT *, BINARY_COMPOUND, ': BINARY COMPOUND'
	READ *, substanceType	
	PRINT *, 'Enter cutoff distance: '
	READ *, RC						 
	!*********************************************************
	! Open input file
	OPEN(1,FILE='relax.xyz', STATUS='OLD')
	! Read first line to get total   
	READ(1,*) totalAtom
	! Skip the second line		
	READ(1,*)				
	! Read coordinates of each atom
	DO i = 1, totalAtom
		READ (1,*) typeAtom, tempX, tempY, tempZ
		! Atom 1
		IF (ATOM1 == typeAtom) THEN
			cntAtom1 = cntAtom1 + 1
			x1(cntAtom1) = tempX
			y1(cntAtom1) = tempY
			z1(cntAtom1) = tempZ
		! Atom 2
		ELSE IF (ATOM2 == typeAtom) THEN
			cntAtom2 = cntAtom2 + 1
			x2(cntAtom2) = tempX
			y2(cntAtom2) = tempY
			z2(cntAtom2) = tempZ
		END IF
	END DO
	PRINT *,'                                          '
    PRINT *,'DR. VO VAN HOANG,DEPT.OF PHYSICS, UNIVERSITY OF HCM CITY'
    PRINT *,'                                                        '
    PRINT *,'.....PROGRAM CALCULATING THE BOND-ANGLE DISTRIBUTION....'
    PRINT *,'................PROGRAM STARTED.........................'

	! Set init values
	count = RC * 100
	DO i = 1, ACCURACY
		  distance12(i)=0
		  distance21(i)=0
	END DO
	SELECT CASE (substanceType)
		CASE (SINGLE)
			! Create output file
			OPEN(2,FILE='distance.dat', STATUS='UNKNOWN')
			! Calculate coor number
			CALL calculateInterDistanceSingle(x1,y1,z1,cntAtom1,distance12)
			! Write output file  
			CALL writeOutput(2,distance12) 
		CASE (BINARY_COMPOUND)
			OPEN(2,FILE='distance12.dat', STATUS='UNKNOWN')
			OPEN(3,FILE='distance21.dat', STATUS='UNKNOWN')
			CALL calculateInterDistanceBinary(x1,y1,z1,x2,y2,z2,cntAtom1,cntAtom2,distance12,distance21)
			PRINT *,'COOR NUMBER OF ATOM 1'
			CALL writeOutput(2,distance12) 	
			PRINT *,'COOR NUMBER OF ATOM 2'
			CALL writeOutput(3,distance21) 
	END SELECT           
    PRINT *,'PROGRAM ENDED'
	CONTAINS
		!*********************************************************
		SUBROUTINE calculateInterDistanceSingle(x,y,z,cntAtom,distanceNum)
		INTEGER i, j, cntAtom, distance
		REAL, DIMENSION(MAX) :: x, y, z
		INTEGER, DIMENSION(MAX) :: distanceNum
		! INTERATOMIC DISTANCE
		DO i = 1, cntAtom
			DO j = 1, cntAtom
				IF (i.NE.j) THEN
					distance = calculateR(x(i),y(i),z(i),x(j),y(j), z(j))
					IF (distance > ACCURACY) distanceNum(distance) = distanceNum(distance) + 1
				END IF 
			END DO
		END DO
		END SUBROUTINE
		!*********************************************************
		SUBROUTINE calculateInterDistanceBinary(x1,y1,z1,x2,y2,z2,cntAtom1, cntAtom2, distance12, distance21)
		INTEGER i, j, cntAtom1, cntAtom2, distance  
		REAL, DIMENSION(MAX) :: x1, y1, z1, x2, y2, z2
		INTEGER, DIMENSION(MAX) :: distance12, distance21
		! INTERATOMIC DISTANCE 12
		DO i = 1, cntAtom1
			DO j = 1, cntAtom2
				distance = calculateR(x1(i),y1(i),z1(i),x2(j),y2(j), z2(j))
				IF (distance > ACCURACY) distance12(distance) = distance12(distance) + 1 
			END DO
		END DO
		! INTERATOMIC DISTANCE 21
		DO i = 1, cntAtom2
			DO j = 1, cntAtom1
				distance = calculateR(x2(i),y2(i),z2(i),x1(j),y1(j), z1(j))
				IF (distance > ACCURACY) distance21(distance) = distance21(distance) + 1 
			END DO
		END DO
		END SUBROUTINE
		!*********************************************************
		SUBROUTINE writeOutput(unit, distanceNum)
			INTEGER i, count, unit
			INTEGER, DIMENSION(MAX) :: distanceNum
			REAL distance
			count = RC * ACCURACY	
			DO i = 1, count
				distance = 	REAL(i)/ACCURACY
				PRINT 100, distance,  distanceNum(i)
				WRITE(unit,100)distance, distanceNum(i) 
			END DO
			100 FORMAT(F10.3,I8)
			CLOSE(unit)
		END SUBROUTINE
		!*********************************************************
		FUNCTION calculateR(x1, y1, z1, x2, y2, z2) RESULT (R)
			REAL x1, y1, z1, x2, y2, z2, R
			R  = (x2 - x1)**2 +(y2 - y1)**2 +(z2 - z1)**2
			R = SQRT(R)	
			IF (R.LE.RC) THEN
				R = NINT(ACCURACY*R)
			END IF
		END FUNCTION

	END
