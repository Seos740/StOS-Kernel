#include "fileops.h"

EFI_STATUS EFIAPI efi_main(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE *SystemTable) {
    EFI_STATUS Status;

    // Example usage of LoadAndJumpToFile from file_ops.h
    Status = LoadAndJumpToFile(ImageHandle, SystemTable, L"example.efi");
    if (EFI_ERROR(Status)) {
        Print(L"Error loading the file.\n");
    }

    // Example of using OpenFile to open a different file
    EFI_FILE_PROTOCOL *FileHandle;
    EFI_FILE_PROTOCOL *RootDir;
    Status = gBS->HandleProtocol(gImageHandle, &gEfiSimpleFileSystemProtocolGuid, (VOID **)&RootDir);
    if (EFI_ERROR(Status)) {
        Print(L"Error opening root directory.\n");
    } else {
        Status = OpenFile(RootDir, L"example.txt", &FileHandle);
        if (EFI_ERROR(Status)) {
            Print(L"Error opening file.\n");
        } else {
            Print(L"File opened successfully.\n");
            // Perform operations with the file handle
            FileHandle->Close(FileHandle);
        }
    }

    return EFI_SUCCESS;
}
