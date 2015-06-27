!     Last change:  123  30 Jun 2005    1:38 pm
!     DR. VO VAN HOANG
!     DEPARTMENT OF PHYSICS, NATIONAL UNIVERSITY OF HOCHIMINH CITY-VIETNAM
!
!     PROGRAM CALCULATING THE COORDINATION NUMBER DISTRIBUTION
!
    IMPLICIT NONE
	! Define constant
	INTEGER, PARAMETER :: ATOM1 = 1, ATOM2 = 2, MAX = 900000, MAX_COORNUM = 30, SINGLE = 1, BINARY_COMPOUND = 2
	! Cutoff
    REAL RC 
	! Coordinate of each atom
	REAL, DIMENSION(MAX) :: x, y, z
	! Atom
	INTEGER, DIMENSION(MAX) :: atom
	! Coornum
	INTEGER, DIMENSION(MAX_COORNUM) :: coornumAtom1, coornumAtom2

	INTEGER :: totalAtom = 0, substanceType = 0
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
	! Read coordinates of all atom
	DO i = 1, totalAtom
		READ (1,*) atom(i), x(i), y(i), z(i)
	END DO
	PRINT *,'                                          '
    PRINT *,'DR. VO VAN HOANG,DEPT.OF PHYSICS, UNIVERSITY OF HCM CITY'
    PRINT *,'                                                        '
    PRINT *,'.....PROGRAM CALCULATING THE BOND-ANGLE DISTRIBUTION....'
    PRINT *,'................PROGRAM STARTED.........................'

	! Set init values
	DO i = 1, MAX_COORNUM
		coornumAtom1(i)=0
		coornumAtom2(i)=0
	END DO

	SELECT CASE (substanceType)
		CASE (SINGLE)
			! Create output file
			OPEN(2,FILE='coornum.dat', STATUS='UNKNOWN')
			! Calculate coor number
			CALL calculateCoorNum(ATOM1,atom,x,y,z)
			! Write output file  
			CALL writeOutput(2,coornumAtom1) 
		CASE (BINARY_COMPOUND)
			! ATOM 1
			OPEN(2,FILE='coornumAtom1.dat', STATUS='UNKNOWN')
			CALL calculateCoorNum(ATOM1,atom,x,y,z)
			PRINT *,'COOR NUMBER OF ATOM 1'
			CALL writeOutput(2,coornumAtom1) 	
			! ATOM 2
			OPEN(3,FILE='coornumAtom2.dat', STATUS='UNKNOWN')
			CALL calculateCoorNum(ATOM2,atom,x,y,z)
			PRINT *,'COOR NUMBER OF ATOM 2'
			CALL writeOutput(3,coornumAtom2) 
	END SELECT           
    PRINT *,'PROGRAM ENDED'
	CONTAINS
		!*********************************************************
		SUBROUTINE calculateCoorNum(desiredType, atom,x,y,z)	
			INTEGER, DIMENSION (MAX) :: atom
			INTEGER atomType, desiredType, value,i,j
			REAL, DIMENSION (MAX) :: x,y,z
			REAL :: r = 0
			DO i = 1, totalAtom
				atomType = atom(i)
				IF (atomType == desiredType) THEN
					value = 0;
					DO j = 1, totalAtom
						IF (i.NE.j) THEN
							r = (x(i) - x(j))**2 +(y(i) - y(j))**2 +(z(i) - z(j))**2
							r =	 SQRT(r)
							IF (r.LE.RC) value = value + 1
						END IF
					END DO
					IF (ATOM1 == desiredType) THEN
							coornumAtom1(value) = coornumAtom1(value) + 1
					ELSE IF (ATOM2 == desiredType)	THEN
							coornumAtom2(value) = coornumAtom2(value) + 1
					END IF
				END IF
			END DO
		END SUBROUTINE
		!*********************************************************
		SUBROUTINE writeOutput(unit, coornum)
			INTEGER i, unit
			INTEGER, DIMENSION(MAX_COORNUM) :: coornum
			DO i = 1, MAX_COORNUM
				PRINT *, i,  coornum(i)
				WRITE(unit,100)i, coornum(i) 
			END DO
			100 FORMAT(2I8)
			CLOSE(unit)
		END SUBROUTINE
	END
