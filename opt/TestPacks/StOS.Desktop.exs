Name: .StOS.Desktop
Memory: 64000KB
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main() {
    srand(time(NULL));
    int arr[10];
    for(int i = 0; i < 10; i++) {
        arr[i] = rand() % 100;
        printf("arr[%d] = %d\n", i, arr[i]);
    }
    return 0;
}        