/* Copyright (c) 2009 Jon Maken
 * Revision: 12/21/2009 12:13:17 PM
 * License: MIT
 *
 * compile with:
 *   gcc -DWINVER=0x0501 -Wall -o fakeruby.exe fakeruby.c
 *   llvm-gcc -DWINVER=0x0501 -Wall -o fakeruby.exe fakeruby.c
 *   cl /DWINVER=0x0501 fakeruby.c
 */

#include <windows.h>
#include <stdio.h>

static const char* FAKERUBY_VERSION = "1.0";
static const int ARG_MAX = 10;
static const int BUFSIZE = 32767;

#define say_newline() printf("\n")

#ifdef _MSC_VER
  static const char* COMPILER = "MSVC";
  static const int COMPILER_VERSION = _MSC_FULL_VER;
#elif defined(__MINGW32__)
  static const char* COMPILER = "MinGW";
  static const int COMPILER_VERSION = __GNUC__ * 10000 + __GNUC_MINOR__ * 100 + __GNUC_PATCHLEVEL__;
#endif

static void say_header(void)
{
	printf("FakeRuby v%s [%s v%u] (pid = %lu)\n",
			FAKERUBY_VERSION, COMPILER, COMPILER_VERSION, GetCurrentProcessId());
}

static void say_args(int argc, char** argv)
{
	int max = 0;
	int c;

	if (argc > ARG_MAX + 1)
		max = ARG_MAX;
	else
		max = argc;

	for (c = 1; c < max; c++)
		printf("arg[%i] = %s\n", c, argv[c]);

	if (argc > ARG_MAX)
		printf("<%i more args given, elided...>\n", argc - ARG_MAX);
}

static void say_env_var(CHAR* buf, CHAR* env_var)
{
	DWORD rv;

	memset(buf, 0, BUFSIZE * sizeof(CHAR));
	rv = GetEnvironmentVariable(env_var, buf, BUFSIZE);
	if (rv == 0) return;
	printf("\n%s = %s\n", env_var, buf);
}

int main(int argc, char** argv)
{
	CHAR* buf = calloc(1, BUFSIZE * sizeof(CHAR));
	if (buf == NULL) return -1;

	say_header();

	if (argc > 1) {
		say_newline();
		say_args(argc, argv);
	}

	say_env_var(buf, "PATHEXT");
	say_env_var(buf, "PATH");
	
	free(buf);

	return 0;
}
