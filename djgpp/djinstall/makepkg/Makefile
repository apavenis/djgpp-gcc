CXX = g++
CXXFLAGS = -std=c++17 -Og -Wall -g3

SRCS = \
	main.cpp \
	PkgBuilder.cpp \
	CppRename.cpp \
	CRename.cpp \
	FileRename.cpp \
	FileRemove.cpp \
	ManifestDefs.cpp \
	ManifestInfo.cpp

OBJS = $(patsubst %.cpp,%.o,$(SRCS))

all:	makepkg

clean:
	rm -f makepkg $(OBJS)

makepkg: $(OBJS)
	$(CXX) $(CXXFLAGS) $(OBJS) -o $@ -lstdc++

%o : %.cpp;  $(CXX) -o $@ $< -M $CXXFLAGS

-include $(wildcard src/*.d)
