#include <stdio.h>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>

int list(void) {
    DIR *dirp = opendir(MANDIR);
    struct dirent *dp;
    int n = 0;
    while ((dp = readdir(dirp)) != NULL) {
        size_t len = strlen(dp->d_name);
        if (len < 3)
            continue;
        if (strcmp(dp->d_name + (len - 2), ".7") == 0) {
            dp->d_name[len - 2] = '\0'; /* truncate extension */
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
        size_t len = strlen(dp->d_name);
        if (len < 3)
            continue;
        if (strcmp(dp->d_name + (len - 2), ".7") == 0) {
            if (++i == choice) {
                char *cmd_base = "mandoc -l";
                char cmd[sizeof(cmd_base) + PATH_MAX + 2];
                sprintf(cmd, "%s %s/%s", cmd_base, MANDIR, dp->d_name);
                system(cmd);
                break;
            }
        }
    }
    closedir(dirp);
}

void prompt(int n) {
    printf("choice> ");
    fflush(stdout);

    /* NOTE: Read from /dev/tty instead of stdin to prevent
     * simple DDOS via < /dev/random */

    FILE *tty = fopen("/dev/tty", "r");
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
    int n = list();
    setenv("MANPAGER", "less", 0);
    setenv("LESSSECURE", "1", 1);
    for(;;)
        prompt(n);
    return 0;
}
