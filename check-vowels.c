#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void reverse_vowels(char *string);

const char *filler = "========================================";
const char *delim  = "........................................";

void read_input(int test_no, char *input)
{
    char file[16] = {};
    sprintf(file, "in/vow-%02d.in", test_no);

    FILE *in = fopen(file, "r");
    if (!in) {
        printf("Cannot find input file\n");
        exit(EXIT_FAILURE);
    }

    fgets(input, 2e7, in);
}

void read_ref(int test_no, char *ref)
{
    char file[16] = {};
    sprintf(file, "ref/vow-%02d.ref", test_no);

    FILE *ref_file = fopen(file, "r");
    if (!ref_file) {
        printf("Cannot find ref file\n");
        exit(EXIT_FAILURE);
    }

    fgets(ref, 2e7, ref_file);
}

void write_out(int test_no, char *out)
{
    char file[16] = {};
    sprintf(file, "out/vow-%02d.out", test_no);

    FILE *out_file = fopen(file, "w");
    if (!out_file) {
        printf("Cannot create out file\n");
        exit(EXIT_FAILURE);
    }

    fprintf(out_file, "%s", out);
}

void run_tests(int test_num, int silent_testing)
{
    float score = 0.0f;
    float score_per_test = 20.0f / test_num;

    int filler_size = (50 - strlen("REVERSE VOWELS")) / 2;
    int delim_size = 50 - strlen("Test 00XXXXXX: 0.00");

    printf("%.*sREVERSE VOWELS%.*s\n\n", filler_size, filler, filler_size, filler);

    for (size_t i = 0; i < test_num; i++) {
        char *input = malloc(2e6);
        char *ref = malloc(2e6);
        read_input(i, input);
        read_ref(i, ref);

        reverse_vowels(input);

        write_out(i, input);

        if (strcmp(input, ref) == 0) {
            printf("Test %02d%.*sPASSED: %.2f\n", i, delim_size, delim, score_per_test);
            score += score_per_test;
        } else {
            printf("Test %02d%.*sFAILED: %.2f\n", i, delim_size, delim, 0.0);
        }
    }
    printf("\nTASK 1 SCORE: %.2f / 20.00\n", score);
}

int main(int argc, char **argv)
{
    int is_silent = 1;
    if (argc == 2 && 
        (strcmp(argv[1], "-o") == 0 || strcmp(argv[1], "--output") == 0)) {
        is_silent = 0;
    }

    run_tests(10, is_silent);

    return 0;
}
