.SUFFIXES: .f .F .F90 .f90 .o .mod
.SHELL: /bin/sh

# PATH options
srcdir = src
objdir = libyelmox/include
bindir = libyelmox/bin
libdir = libs

# Command-line options at make call
debug    ?= 0
parallel ?= 0 

## COMPILER CONFIGURATION ##
# (should be loaded from config directory)

FC  = gfortran

NETCDF_FORTRANROOT=/work/zolles/libs/system
INC_NC  = -I${NETCDF_FORTRANROOT}/include
LIB_NC  = -L${NETCDF_FORTRANROOT}/lib -lnetcdff -Wl,-rpath -Wl,/work/zolles/libs/system/lib

YELMOROOT = /work2/pwegmann/repos/remote/yelmo
INC_YELMO = -I${YELMOROOT}/libyelmo/include
LIB_YELMO = -L${YELMOROOT}/libyelmo/include -lyelmo

LISROOT = /work2/pwegmann/scripts/libs/lis
INC_LIS = -I${LISROOT}/include
LIB_LIS = -L${LISROOT}/lib/ -llis

FFLAGS = -m64 -ffree-line-length-none -I$(objdir) -J$(objdir)

LFLAGS  = $(LIB_YELMO) $(LIB_NC) $(LIB_LIS) -Wl,-zmuldefs

DFLAGS_NODEBUG = -O2
DFLAGS_DEBUG   = -w -g -p -ggdb -ffpe-trap=invalid,zero,overflow -fbacktrace -fcheck=all
DFLAGS_PROFILE = -O2 -p -ggdb



# Determine whether to use normal flags or debugging flags
DFLAGS   = $(DFLAGS_NODEBUG)
ifeq ($(debug), 1)
	DFLAGS   = $(DFLAGS_DEBUG)
endif

# Debugging flags with profiling output enabled
ifeq ($(debug), 2)
	DFLAGS   = $(DFLAGS_PROFILE)
endif

###############################################
##
## List of yelmox rules and source files
##
###############################################

include config/Makefile_yelmox.mk

###############################################
##
## Compilation of complete programs
##
###############################################

# Compile the static library libyelmo,
# using Makefile located in $(YELMOROOT) directory 
yelmo-static: 
		$(MAKE) -C $(YELMOROOT) yelmo-static parallel=$(parallel)

# Compile the static library libyelmo,
# using Makefile located in $(YELMOROOT) directory 
rembo-static: 
		$(MAKE) -C $(REMBOROOT) rembo-static 

yelmox : yelmo-static $(yelmox_libs)
		$(FC) $(DFLAGS) $(FFLAGS) $(INC_LIS) $(INC_YELMO) -o $(bindir)/yelmox.x yelmox.f90 \
			$(LFLAGS) $(yelmox_libs) 
		@echo " "
		@echo "    yelmox.x is ready."
		@echo " "

yelmox_hyst : yelmo-static $(yelmox_libs)
		$(FC) $(DFLAGS) $(FFLAGS) $(INC_LIS) $(INC_YELMO) -o $(bindir)/yelmox_hyst.x yelmox_hyst.f90 \
			$(LFLAGS) $(yelmox_libs) 
		@echo " "
		@echo "    yelmox_hyst.x is ready."
		@echo " "

yelmox_iso : yelmo-static $(yelmox_libs)
		$(FC) $(DFLAGS) $(FFLAGS) $(INC_LIS) $(INC_YELMO) -o $(bindir)/yelmox_iso.x yelmox_iso.f90 \
			$(LFLAGS) $(yelmox_libs) 
		@echo " "
		@echo "    yelmox_iso.x is ready."
		@echo " "

yelmox_ismip6 : yelmo-static $(yelmox_libs)
		$(FC) $(DFLAGS) $(FFLAGS) $(INC_LIS) $(INC_YELMO) -o $(bindir)/yelmox_ismip6.x yelmox_ismip6.f90 \
			$(LFLAGS) $(yelmox_libs) 
		@echo " "
		@echo "    yelmox_ismip6.x is ready."
		@echo " "

yelmox_rembo: yelmo-static rembo-static $(yelmox_libs)
	$(FC) $(DFLAGS) $(FFLAGS) $(INC_LIS) $(INC_YELMO) $(INC_REMBO) -o libyelmox/bin/yelmox_rembo.x \
			yelmox_rembo.f90 $(LIB_REMBO) $(LFLAGS) $(yelmox_libs)
	@echo " "
	@echo "    libyelmox/bin/yelmox_rembo.x is ready."
	@echo " "

check_sim : $(objdir)/ncio.o
		$(FC) $(DFLAGS) $(FFLAGS) -o ./check_sim.x check_sim.f90 \
			$(LFLAGS) $(objdir)/ncio.o
		@echo " "
		@echo "    check_sim.x is ready."
		@echo " "

.PHONY : usage
usage:
	@echo ""
	@echo "    * USAGE * "
	@echo ""
	@echo " make yelmox     : compiles yelmox.x, for running yelmo on a given domain defined in param file."
	@echo " make clean      : cleans object files"
	@echo ""

clean:
	rm -f $(bindir)/*.x
	rm -f  *.x gmon.out $(objdir)/*.o $(objdir)/*.mod $(objdir)/*.a $(objdir)/*.so
	rm -rf *.x.dSYM
	rm -f ${YELMOROOT}/libyelmo/include/*.a ${YELMOROOT}/libyelmo/include/*.o 

