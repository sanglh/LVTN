IMPLICIT NONE
	! Define constant
	INTEGER, PARAMETER :: ATOM1 = 1, ATOM2 = 2, MAX = 900000,  SINGLE = 1, BINARY_COMPOUND = 2
    REAL, PARAMETER :: PI = 3.14159
	! Temporary coordinate
	REAL tempX, tempY, tempZ
	! Coordinate of each atom
	REAL, DIMENSION(MAX) :: x1, y1, z1, x2, y2, z2
	! Number of atom
	INTEGER :: typeAtom = 0, cntAtom1 = 0, cntAtom2 = 0, totalAtom = 0
	! Loop variable
	INTEGER i,j  , frames, startT, stepT, currT
	CHARACTER *23 f
	! TOTAL FRAMES
	frames =  129
	startT = 50
	stepT = 50
	!*********************************************************
					 
	!*********************************************************
	! Open input file
	OPEN(1,FILE='liquid.xyz', STATUS='OLD')
	! Read first line to get total   
	READ(1,*) totalAtom
	! Skip the second line		
	READ(1,*)
	! Read coordinates of each atom
	DO i = 1, frames
		currT = startT * (1 + i)
		write(f,*) currT
			OPEN(2,FILE=f//'.xyz', STATUS='UNKNOWN')
			CALL createXYZFormat(2, totalAtom) 

		DO j = 1, totalAtom
		
			READ (1,*) typeAtom, tempX, tempY, tempZ
			! Atom 1
			IF (ATOM1 == typeAtom) THEN
				CALL writeXYZFormat(2, tempX, tempY, tempZ,' Si ')
			! Atom 2
			ELSE IF (ATOM2 == typeAtom) THEN
				CALL writeXYZFormat(2, tempX, tempY, tempZ,' C  ')

			END IF
		END DO

		CLOSE(2)
		! Skip the second line		
		READ(1,*)
		! Skip the second line		
		READ(1,*)
	
	END DO

	CONTAINS
	  !*********************************************************
		SUBROUTINE createXYZFormat(unit, totalCnt)   
		    INTEGER unit, totalCnt
			WRITE(unit,*)totalCnt
			WRITE(unit,*)"        "
		END SUBROUTINE
		SUBROUTINE writeXYZFormat(unit, x, y, z,name)   
			REAL :: x,y,z
			CHARACTER*4 name
			INTEGER unit
			WRITE(unit,*)name,x,y,z
		END SUBROUTINE
	END
