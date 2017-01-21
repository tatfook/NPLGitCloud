#include <stdio.h>
#include <string.h>

void buffer2hexstring(const unsigned char* buffer, size_t bufferLen, char* result){
	for(int i = 0; i < bufferLen; i++){
		result += sprintf(result, "%02x", buffer[i]);
	}
}