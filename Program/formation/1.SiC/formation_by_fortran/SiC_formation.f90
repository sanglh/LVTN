
	IMPLICIT NONE
	!******************************************
	! Define constant
	INTEGER, PARAMETER :: MAX = 900000, PI = 3.14159
	CHARACTER * 4, PARAMETER :: ATOM1 = ' 1 ', ATOM2 = ' 2 '
    ! Coordinate of each atom												 
	REAL, DIMENSION(MAX) :: x1,y1,z1,x2,y2,z2
	REAL :: zh = 0.5 !half z height
	REAL :: bondSiC = 1.786 ! Bond lenght Si-C
	REAL initX, periodX, initY, periodY
	INTEGER :: cntSi = 0, cntC = 0, totalCnt = 0, nodeX =0, nodeY = 0
	!*********************************************************
	! Ask for user choice
	PRINT *, "Enter total atom( divisible by 4 ): "
	READ *, totalCnt
	!*********************************************************

	CALL calculateNode(totalCnt, nodeX, nodeY)
	periodX = bondSiC * (MCOS(60.0) + 1 + MCOS(60.0) + 1)
	periodY = bondSiC * 2 * MSIN(60.0)
	! COLUMN 1 : C
	initX = 0
	initY = bondSiC * MSIN(60.0)
	CALL createCoordinate(initX, periodX, initY, periodY, x2, y2, z2, nodeX, nodeY, cntC)
	! COLUMN 2 : Si
	initX = bondSiC * MCOS(60.0)
	initY = 0
	CALL createCoordinate(initX, periodX, initY, periodY, x1, y1, z1, nodeX, nodeY, cntSi)
	! COLUMN 3 : C
	initX = bondSiC * (MCOS(60.0) + 1)
	initY = 0
	CALL createCoordinate(initX, periodX, initY, periodY, x2, y2, z2, nodeX, nodeY, cntC)
	! COLUMN 4 : Si
	initX = bondSiC * (MCOS(60.0) + 1 + MCOS(60.0))
	initY = bondSiC * MSIN(60.0)
	CALL createCoordinate(initX, periodX, initY, periodY, x1, y1, z1, nodeX, nodeY, cntSi)
	! Write lammps file
	OPEN(1,FILE='SiC.lammpstrj',STATUS='UNKNOWN') 
	CALL writeLammpFormat(1, nodeX, nodeY, periodX, periodY, totalCnt, cntSi, cntC, x1, y1, z1, x2, y2, z2, zh)
	! Write xyz file
	OPEN(2,FILE='SiC.xyz',STATUS='UNKNOWN') 
	CALL writeXYZFormat(2, totalCnt, cntSi, cntC, x1, y1, z1, x2, y2, z2) 
	PRINT *,'COMPLETED'
	CONTAINS
		!*********************************************************
		SUBROUTINE createCoordinate(intX, periodX, initY, periodY, x, y, z, nodeX, nodeY, cnt)
			REAL, DIMENSION(MAX) :: x, y, z
			REAL intX, periodX, initY, periodY
			INTEGER nodeX, nodeY, cnt, i, j
			DO i=1, nodeX     
				DO j=1, nodeY       
					cnt=cnt+1
					x(cnt)=intX + i * periodX 
					y(cnt)=initY + j * periodY
					z(cnt)=0
				END DO
       		END DO
		END SUBROUTINE
		!*********************************************************
		SUBROUTINE writeLammpFormat(unit,nodeX, nodeY, periodX, periodY, totalCnt, cntSi, cntC, x1, y1, z1, x2, y2, z2, zh)   
			REAL, DIMENSION(MAX) :: x1, y1, z1, x2, y2, z2
			REAL periodX, periodY, zh
			INTEGER unit,nodeX, nodeY, totalCnt, cntSi, cntC, i
			WRITE(unit,'(A8)')'        '    
			WRITE(unit,'(A8)')'        '
			WRITE(unit,*)totalCnt," atoms "
			WRITE(unit,*)2," atom types "
			WRITE(unit,*)"        "
			WRITE(unit,*)0.0,nodeX*periodX  ," xlo xhi "
			WRITE(unit,*)0.0,nodeY*periodY  ," ylo yhi "
			WRITE(unit,*)-zh,zh," zlo zhi "
			WRITE(unit,'(A8)')'        '
			WRITE(unit,'(A8)')'Atoms   '
			WRITE(unit,'(A8)')'        '  
			DO i = 1, cntSi 
				WRITE(unit,*)ATOM1,x1(i),y1(i),z1(i)
			END DO
			DO i = 1, cntC 
				WRITE(unit,*)ATOM2,x2(i),y2(i),z2(i)
			END DO
			CLOSE(unit)
	  END SUBROUTINE
	  !*********************************************************
	  SUBROUTINE writeXYZFormat(unit, totalCnt, cntSi, cntC, x1, y1, z1, x2, y2, z2)   
			REAL, DIMENSION(MAX) :: x1, y1, z1, x2, y2, z2
			INTEGER unit, totalCnt, cntSi, cntC, i
			WRITE(unit,*)totalCnt
			WRITE(unit,*)"        "
			DO i = 1, cntSi 
				WRITE(unit,*)'Si',x1(i),y1(i),z1(i)
			END DO
			DO i = 1, cntC 
				WRITE(unit,*)'C',x2(i),y2(i),z2(i)
			END DO
			CLOSE(unit)
	  END SUBROUTINE
	  !*********************************************************
	  SUBROUTINE calculateNode(totalCnt, nodeX, nodeY)
			INTEGER totalCnt, nodeX, nodeY, totalNode
			totalNode =  totalCnt / 4
			nodeY= SQRT(1.0 * totalNode)
			IF ((nodeY * nodeY).NE.(totalNode)) nodeY = 50
			nodeX = totalNode / nodeY
			IF ((nodeX * nodeY).NE.(totalNode)) nodeY = 10
			nodeX = totalNode / nodeY
			IF ((nodeX * nodeY).NE.(totalNode)) nodeY = 5
			nodeX = totalNode / nodeY
			IF ((nodeX * nodeY).NE.(totalNode)) nodeY = 2
			nodeX = totalNode / nodeY
			IF ((nodeX * nodeY).NE.(totalNode)) nodeY = 1
			nodeX = totalNode / nodeY
		END SUBROUTINE
		!*********************************************************
		FUNCTION MCOS(degree) RESULT (coz)
			REAL degree, coz
			coz = COS(degree * PI / 180.0)
		END FUNCTION
		FUNCTION MSIN(degree)RESULT (zin)
			REAL degree, zin
			zin = SIN(degree * PI / 180.0)
		END FUNCTION
		!*********************************************************
	END

         
