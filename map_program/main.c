#include <windows.h>
#include <stdio.h>

void process_com(HANDLE h_com) {
    (void *) 0;
}

int main(void) {
    HANDLE h_com;
    
    h_com = CreateFile("\\\\.\\COMx",
                        GENERIC_READ,
                        0,
                        NULL,
                        OPEN_EXISTING,
                        0,
                        NULL);
    
    if (h_com == INVALID_HANDLE_VALUE) {
        fprintf(stderr, "Failed to open COM.\n");
    } else {
        process_com(h_com);
    }

    CloseHandle(h_com);

    return 0;
}