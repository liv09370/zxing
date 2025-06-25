SHELL = /bin/sh
CXX = g++
CXXFLAGS =  -I/home/sanyu/source/zxing_cpp.rb/ext/zxing/zxing-cpp/core/src -fPIC
LDFLAGS = -lstdc++ /home/sanyu/source/zxing_cpp.rb/ext/zxing/zxing-cpp/build/core/libZXing.a
LDSHARED = g++ -shared

TARGET = zxing.so
OBJS = zxing.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LDSHARED) $(OBJS) $(LDFLAGS) -o $(TARGET)

zxing.o: zxing.cc
	$(CXX) $(CXXFLAGS) -c zxing.cc -o zxing.o

clean:
	rm -f $(OBJS) $(TARGET)

install: $(TARGET)
	# 动态库构建完成

.PHONY: all clean install
