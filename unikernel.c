#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>

void fail(const char* msg)
{
	printf("FAIL: %s\n", msg);
	_exit(1);
}

#define INBOUND_PORT 14902
#define OUTBOUND_HOST "127.0.0.1"
#define OUTBOUND_PORT 8080

int main(int argc, const char **argv)
{
	int in = socket(AF_INET, SOCK_DGRAM, 0);
	if (in == -1)
		fail("UDP socket");

	struct sockaddr_in in_addr = { 0 };
	in_addr.sin_family = AF_INET;
	in_addr.sin_port = htons(INBOUND_PORT);
	in_addr.sin_addr.s_addr = htonl(INADDR_ANY);

	if (bind(in, (struct sockaddr*)&in_addr, sizeof(in_addr)) != 0)
		fail("UDP bind");

	int out = socket(AF_INET, SOCK_STREAM, 0);
	if (out == -1)
		fail("TCP socket");

	struct sockaddr_in out_addr = { 0 };
	out_addr.sin_family = AF_INET;
	out_addr.sin_port = htons(OUTBOUND_PORT);
	out_addr.sin_addr.s_addr = inet_addr(OUTBOUND_HOST);

	if (connect(out, (struct sockaddr*)&out_addr, sizeof(out_addr)) != 0)
		fail("TCP connect");

	const unsigned BUFFER_SIZE = 256;
	char buffer[BUFFER_SIZE];
	memset(buffer, 0, BUFFER_SIZE);
	buffer[0] = ' ';
	buffer[1] = ' ';

	while (1)
	{
		int n = read(in, buffer+2, BUFFER_SIZE-2);
		if (n < 1)
		{
			printf("read %d bytes\n", n);
		  continue;
		}

		switch(buffer[2])
		{
			case 'y':
				buffer[0] = 'B';
				write(out, buffer, n+2);
				break;
			case 'n':
				buffer[0] = 'S';
				write(out, buffer, n+2);
				break;
		}
	}

	return 0;
}
