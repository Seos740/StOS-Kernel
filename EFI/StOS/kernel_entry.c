#include <efi.h>
#include <efilib.h>

EFI_STATUS
EFIAPI
efi_main(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE *SystemTable) {
    InitializeLib(ImageHandle, SystemTable);

    EFI_SIMPLE_TEXT_INPUT_PROTOCOL *ConIn;
    EFI_INPUT_KEY Key;

    // Locate the keyboard input protocol
    EFI_STATUS Status = SystemTable->BootServices->LocateProtocol(
        &gEfiSimpleTextInProtocolGuid,
        NULL,
        (VOID **)&ConIn
    );

    if (EFI_ERROR(Status)) {
        Print(L"Failed to locate keyboard input protocol.\n");
        return Status;
    }

    // Boot success message and initial prompt
    Print(L"StOS Booted Into Kernel Successfully!\n");
    Print(L"StOS $ ");

    while (1) {
        // Read and display typed characters
        Status = ConIn->ReadKeyStroke(ConIn, &Key);
        if (!EFI_ERROR(Status)) {
            Print(L"%c", Key.UnicodeChar);
        }
    }

    return EFI_SUCCESS;
}
