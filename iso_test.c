#include <stdio.h>

int main(int argc, const char **argv)
{
	printf("%d args:\n", argc);
	for (int i = 0; i < argc; ++i)
		printf("%d: %s\n", i, argv[i]);
}
