     
    IMPLICIT NONE
	! Dinh nghia hang so
	INTEGER, PARAMETER ::  MAX = 900000, MAX_NEIGHBOR = 4
	! Toa do cua cac nguyen tu trong cac frames
	REAL, DIMENSION(MAX) :: x, y, z
	! MSD 
	INTEGER, DIMENSION(MAX) :: MSD
	! Tong so nguyen tu
	INTEGER :: totalAtom = 0
	! Tong so frames
	INTEGER :: totalFrames = 0
	! Bien vong lap
	INTEGER i, j, count, status
					 
	!*************************************************************************
	! Doc file xac dinh tong so nguyen tu 
	OPEN(1,FILE='heating.xyz', STATUS='OLD')
	! Doc dong dau tien   
	READ(1,*) totalAtom
	CLOSE(1)

	! Doc file xac dinh tong so frames
	DO
		! Doc tong so nguyen tu   
		READ(1,*,IOSTAT = status)
		IF (status == 0) THEN
			totalFrames = totalFrames + 1
			CALL skip(1,totalAtom+1)
		ELSE
			EXIT
		END IF
	END DO
	CLOSE(1)

	PRINT *, 'TONG SO ATOMS',totalAtom
	PRINT *, 'TONG SO FRAMES',totalFrames   
    PRINT *,'PROGRAM ENDED'
	CONTAINS
		!*********************************************************
		SUBROUTINE skip(unit, lines)
			INTEGER i, status, unit, lines
			DO i = 1, lines
				READ(unit,*,IOSTAT = status)
					IF (status < 0) THEN
						EXIT
					END IF
			END DO
		END SUBROUTINE
		!*********************************************************

	END
