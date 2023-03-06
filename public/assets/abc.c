#include <stdio.h>
int main(int argc, char** argv) {
    printf("Hello, %s\n", "Reid Hopkins"); // a string
    printf("The year is %d\n", 2022); // a decimal number
    printf("Hello, %s\n", "Reid Hopkins", 2022); // a string and an unused number
    printf("Hello, %p\n", "Reid Hopkins"); // a "pointer" which segfaults immediately
    printf("Hello, %x\n"); // a hexadecimal number pointing to... random stackspace
    return 0;
}
