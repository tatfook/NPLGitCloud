CC=gcc
CFLAGS=-shared -I /usr/local/include/ -L/usr/local/lib 
LIB = -llua -lgit2

all: gitcore.so

gitcore.so: gitcore.c gitcore.h util.c util.h
	$(CC) $(CFLAGS) $(LIB) gitcore.c util.c -o gitcore.so

clean:
	rm gitcore.so