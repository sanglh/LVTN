!     Last change:  123   4 Mar 2005    6:45 am
!     DR. VO VAN HOANG
!     DEPARTMENT OF PHYSICS, NATIONAL UNIVERSITY OF HOCHIMINH CITY-VIETNAM
!
!     PROGRAM CALCULATING THE BOND-ANGLE DISTRIBUTION 212, 121
!     FOR TWO COMPONENT SYSTEM
!     PROGRAM IS WORKING WELL
!
    IMPLICIT NONE
	! Define constant
	INTEGER, PARAMETER :: ATOM1 = 1, ATOM2 = 2, MAX = 900000,  SINGLE = 1, BINARY_COMPOUND = 2
    REAL, PARAMETER :: PI = 3.14159
	! Temporary coordinate
	REAL tempX, tempY, tempZ
	! Coordinate of each atom
	REAL, DIMENSION(MAX) :: x1, y1, z1, x2, y2, z2
	! Cutoff
	REAL RC
	! Angle
	INTEGER, DIMENSION(180) :: angle121, angle212
	! Number of atom
	INTEGER :: typeAtom = 0, cntAtom1 = 0, cntAtom2 = 0, totalAtom = 0, substanceType = 0
	! Loop variable
	INTEGER i
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
	DO i = 1, 180
		angle121(i)=0
		angle212(i)=0
	END DO
	SELECT CASE (substanceType)
		CASE (SINGLE)
			! Create output file
			OPEN(2,FILE='angle.dat', STATUS='UNKNOWN')
			! Calculate angle number
			CALL calculateAngleSingle(x1,y1,z1,cntAtom1,angle212)
			! Write output file  
			CALL writeOutput(2,angle212) 
		CASE (BINARY_COMPOUND)	
			OPEN(2,FILE='angle212.dat', STATUS='UNKNOWN')
			OPEN(3,FILE='angle121.dat', STATUS='UNKNOWN')
			CALL calculateAngleBinary(x1,y1,z1,x2,y2,z2,cntAtom1, cntAtom2, angle212, angle121)
			PRINT *,'COOR NUMBER OF ATOM 1'
			CALL writeOutput(2,angle212) 	
			PRINT *,'COOR NUMBER OF ATOM 2'
			CALL writeOutput(3,angle121) 
	END SELECT           
    PRINT *,'PROGRAM ENDED'
	PRINT *,'            '
    PRINT *,'PROGRAM ENDED'
	!*********************************************************
	CONTAINS
	!*********************************************************
		SUBROUTINE calculateAngleSingle(x,y,z,cntAtom,angle)
			INTEGER i, j, k,  cntAtom, value
			REAL, DIMENSION(MAX) :: x, y, z
			INTEGER, DIMENSION(180) :: angle
			! INTERATOMIC DISTANCE
			DO i = 1, cntAtom
				DO j = 1, cntAtom
					DO k = 1, cntAtom
						IF ((i.NE.j).AND.(i.NE.k).AND.(k.NE.j)) THEN
							value = calculateAngle(x(i),y(i),z(i),x(j),y(j), z(j),x(k),y(k), z(k))
							IF (value > 0) angle(value) = angle(value) + 1
						END IF 
					END DO
				END DO
			END DO
		END SUBROUTINE
		!*********************************************************
		SUBROUTINE calculateAngleBinary(x1,y1,z1,x2,y2,z2,cntAtom1, cntAtom2, angle212, angle121)
			INTEGER i, j, k, cntAtom1, cntAtom2, angle  
			REAL, DIMENSION(MAX) :: x1, y1, z1, x2, y2, z2
			INTEGER, DIMENSION(180) :: angle212, angle121
			! Angle 212
			DO i = 1, cntAtom1
				DO j = 1, cntAtom2
					DO k = j + 1, cntAtom2
						angle = calculateAngle(x1(i),y1(i),z1(i),x2(j),y2(j), z2(j),x2(k),y2(k), z2(k))
						IF (angle > 0) angle212(angle) = angle212(angle) + 1 
					END DO
				END DO
			END DO
			! Angle 121
			DO i = 1, cntAtom2
				DO j = 1, cntAtom1
					DO k = j + 1, cntAtom1
						angle = calculateAngle(x2(i),y2(i),z2(i),x1(j),y1(j), z1(j),x1(k),y1(k), z1(k))
						IF (angle > 0.001) angle121(angle) = angle121(angle) + 1 
					END DO
				END DO
			END DO
		END SUBROUTINE
		!*********************************************************
		FUNCTION calculateAngle(xCenter, yCenter, zCenter, x1, y1, z1, x2, y2, z2) RESULT (angleInteger)
			REAL xCenter, yCenter, zCenter, x1, y1, z1, x2, y2, z2, aa, bb, cc, angle, cosAngle,RCRC
			INTEGER angleInteger
			RCRC = Rc**2
			angleInteger = 0
			aa = (xCenter - x1)**2 +(yCenter - y1)**2 +(zCenter - z1)**2  
			bb = (xCenter - x2)**2 +(yCenter - y2)**2 +(zCenter - z2)**2  
			cc = (x2 - x1)**2 +(y2 - y1)**2 +(z2 - z1)**2	
			IF ((aa.LE.RCRC).AND.(bb.LE.RCRC)) THEN
				IF ((aa == 0).OR.(bb == 0)) RETURN
				cosAngle = (aa + bb - cc) / (2 * SQRT(aa) * SQRT(bb))
				IF ((cosAngle<-1).OR.(cosAngle >1)) RETURN
				angle = ACOS(cosAngle)
				angle = (angle*180)/PI;
				angleInteger = NINT(angle)
			END IF
		END FUNCTION
			!*********************************************************
		SUBROUTINE writeOutput(unit, angle)
			INTEGER i, unit
			INTEGER, DIMENSION(180) :: angle	
			DO i = 1, 180
				PRINT *, i, angle(i)
				WRITE(unit,100)i, angle(i) 
			END DO
			100 FORMAT(2I8)
			CLOSE(unit)
		END SUBROUTINE
	END