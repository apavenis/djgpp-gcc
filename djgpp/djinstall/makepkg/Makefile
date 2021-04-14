ifneq ($(DJGPP),)
CXX := gpp
else
CXX := g++
#CXX := clang++
endif

CXXFLAGS = -std=c++17 -Og -Wall -g3
#-fsanitize=address,undefined

SRCS = \
	main.cpp \
	PkgBuilder.cpp \
	CppRename.cpp \
	CRename.cpp \
	FileRename.cpp \
	FileRemove.cpp \
	MftDefs.cpp \
	ManifestInfo.cpp

OBJS = $(patsubst %.cpp,%.o,$(SRCS))

all:	makepkg.exe

clean:
	rm -f makepkg $(OBJS)

makepkg.exe: $(OBJS)
	echo $(OS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@

%o : %.cpp;  $(CXX) -o $@ $< -M $CXXFLAGS

-include $(wildcard src/*.d)
