#include <dirent.h>
#include <err.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

int list(void) {
	DIR *dirp = opendir(MANDIR);
	struct dirent *dp;
	int n = 0;
	while ((dp = readdir(dirp)) != NULL) {
		/* ignore hidden files (and, conveniently, . and ..) */
		if (dp->d_name[0] != '.') {
			printf("%2d: %s(7)\n", ++n, dp->d_name);
		}
	}
	closedir(dirp);
	printf(" l: list\n");
	printf(" h: help\n");
	printf(" q: quit\n");
	return n;
}

void help(void) {
	printf(
		"Welcome to alexkarle.com's SSH Kiosk!\n"
		"\n"
		"Here you'll find all the mdoc(7) contents of my blog, rendered\n"
		"in their original form via mandoc(1).\n"
		"\n"
		"Currently, due to security concerns, only the blog posts are\n"
		"browsable (and no shell access is given).\n"
		"\n"
		"If you think this is cool, I'd love to hear from you!\n"
		"Drop me a line at alex@alexkarle.com!\n"
	);

}

/* TODO: have list() read into memory so we don't readdir each time! */
void mandoc(int choice) {
	DIR *dirp = opendir(MANDIR);
	struct dirent *dp;
	int i = 0;
	while ((dp = readdir(dirp)) != NULL) {
		if (dp->d_name[0] != '.' && ++i == choice) {
			char path[PATH_MAX];
			sprintf(path, "%s/%s", MANDIR, dp->d_name);
			FILE *fd = fopen(path, "r");
			if (fd == NULL)
				err(1, "open");
			char c;
			while ((c = getc(fd)) != EOF) {
				putc(c, stdout);
			}
			fclose(fd);
			break;
		}
	}
	closedir(dirp);
}

void prompt(int n) {
	printf("kiosk> ");
	fflush(stdout);

	/* NOTE: Read from /dev/tty instead of stdin to prevent
	 * simple DDOS via < /dev/random */

	FILE *tty = fopen("/dev/tty", "r");
	if (tty == NULL)
		errx(1, "unable to open tty");
	char *line = NULL;
	size_t line_len;
	ssize_t nread = getline(&line, &line_len, tty);
	if (nread == -1 || strcmp(line, "q\n") == 0) {
		printf("Goodbye!\n");
		exit(0);
	}
	fclose(tty);

	int choice;
	if (strcmp(line, "l\n") == 0) {
		list();
	} else if (strcmp(line, "h\n") == 0) {
		help();
	} else if (nread == 1) {
		/* must be blank line... no-op */
	} else if (sscanf(line, "%d\n", &choice) == 0) {
		printf("Bad input: %s", line);
	} else if (choice > n || choice <= 0) {
		printf("Choice %d out of bounds\n", choice);
	} else {
		mandoc(choice);
	}

	free(line);
}

int main(void) {
#ifdef __OpenBSD__
	/* All unveils for this proc only (not for less) */
	if (unveil(MANDIR, "r") == -1)
		err(1, "unveil");
	if (unveil("/dev/tty", "r") == -1)
		err(1, "unveil");
	/* no more unveil's past here! requires pledge*/
	if (pledge("stdio rpath", NULL) == -1)
		err(1, "pledge");
#endif
	int n = list();
	setenv("LESSSECURE", "1", 1);
	for(;;)
		prompt(n);
	return 0;
}
