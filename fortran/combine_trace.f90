program combineTrace

implicit none
!------------------------------------------------------

real :: eta, xi, elevation, burial

character (len = 128) :: station, network, band, component, variable

integer :: startStepIndex, stepLength, endStepIndex, stepNumber, stationNumber
integer :: nt,nStation

real, allocatable, dimension(:,:) :: combinedTrace
real, allocatable, dimension(:) :: t
real, allocatable, dimension(:) :: t_temp
real, allocatable, dimension(:) :: trace_temp

character (len = 128) :: dataFolder, backupFolder

character (len = 128) :: STATIONS_file
integer, parameter :: STATIONS_fid = 11
integer :: STATIONS_IOStatus

character (len = 128) :: singleTrace_file
integer, parameter :: singleTrace_fid = 21
integer :: singleTrace_IOStatus

character (len = 128) :: combinedTrace_file
integer, parameter :: combinedTrace_fid = 31
integer :: combinedTrace_IOStatus

!------------------------------------------------------
write(*,*) "Please input: network band component variable &
            startStepIndex stepLength endStepIndex"
read(*,*) network, band, component, variable, &
          startStepIndex, stepLength, endStepIndex

stepNumber = int((endStepIndex - startStepIndex)/stepLength) + 1

! get station number
STATIONS_file = "../backup/STATIONS_"//trim(network)
open(unit = STATIONS_fid, file = STATIONS_file, status = 'old', action = 'read', iostat = STATIONS_IOStatus)
nStation = 0
do
  read(STATIONS_fid, * , iostat = STATIONS_IOStatus)
  if (STATIONS_IOStatus/=0) exit
  nStation = nStation + 1
enddo
close(STATIONS_fid)
stationNumber = nStation

allocate(combinedTrace(stepNumber,stationNumber))
allocate(t(stepNumber))
allocate(t_temp(endStepIndex))
allocate(trace_temp(endStepIndex))

! todo: modify direct access
open(unit = STATIONS_fid, file = STATIONS_file, status = 'old', action = 'read', iostat = STATIONS_IOStatus)
do nStation = 1,stationNumber
  read(STATIONS_fid, * , iostat = STATIONS_IOStatus) station, network, eta, xi, elevation, burial
  singleTrace_file = "../OUTPUT_FILES/"//trim(station)//"."&
              //trim(network)//"."//trim(band)//trim(component)//"."//trim(variable)
  open(unit = singleTrace_fid, file = singleTrace_file, &
       status = 'old', action = 'read', iostat = singleTrace_IOStatus)
  if (singleTrace_IOStatus/=0) exit
  do nt = 1, endStepIndex
      read(singleTrace_fid, *, iostat = singleTrace_IOStatus) t_temp(nt), trace_temp(nt)
  enddo
  close(singleTrace_fid)
  combinedTrace(:,nStation) = trace_temp(startStepIndex:endStepIndex:stepLength)
enddo
close(STATIONS_fid)

t = t_temp(startStepIndex:endStepIndex:stepLength)

combinedTrace_file = "../backup/"//trim(simulationType)//"_"//trim(network)//"_"//trim(band)//&
                  trim(component)//"_"//trim(variable)
open(unit = combinedTrace_fid, file = combinedTrace_file, &
            status = 'replace', action = 'write', iostat = combinedTrace_IOStatus)
do nt = 1,stepNumber
write(combinedTrace_fid, *) t(nt), (combinedTrace(nt,nStation),nStation=1,stationNumber)
enddo
close(combinedTrace_fid)

deallocate(combinedTrace)
deallocate(t)
deallocate(t_temp)
deallocate(trace_temp)
end program
