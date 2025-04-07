#include <efi.h>
#include <efilib.h>

// Function to load a file from a given directory and execute it.
EFI_STATUS LoadAndJumpToFile(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE *SystemTable, IN CHAR16 *FileName) {
    EFI_STATUS Status;
    EFI_SIMPLE_FILE_SYSTEM_PROTOCOL *SimpleFileSystem = NULL;
    EFI_FILE_IO_INTERFACE *Volume = NULL;
    EFI_FILE *Root = NULL;
    EFI_FILE *FileHandle = NULL;
    EFI_FILE_INFO *FileInfo = NULL;
    UINTN FileInfoSize = 0;
    VOID *Buffer = NULL;
    UINTN ReadSize = 0;
    CHAR16 FullFilePath[512];

    // Initialize UEFI library
    InitializeLib(ImageHandle, SystemTable);

    // Construct the full file path
    StrCpy(FullFilePath, L"\\"); // Assuming the file is on the root
    StrCat(FullFilePath, FileName);

    // Locate the Simple File System protocol
    Status = gBS->LocateHandleBuffer(ByProtocol, &gEfiSimpleFileSystemProtocolGuid, NULL, &HandleCount, &HandleBuffer);
    if (EFI_ERROR(Status)) {
        Print(L"Failed to locate Simple File System Protocol.\n");
        return Status;
    }

    // Open the volume
    Status = gBS->HandleProtocol(HandleBuffer[0], &gEfiSimpleFileSystemProtocolGuid, (VOID **)&SimpleFileSystem);
    if (EFI_ERROR(Status)) {
        Print(L"Failed to get Simple File System Protocol.\n");
        return Status;
    }

    // Open the root directory
    Status = SimpleFileSystem->OpenVolume(SimpleFileSystem, &Volume);
    if (EFI_ERROR(Status)) {
        Print(L"Failed to open volume.\n");
        return Status;
    }

    // Open the specific file from the directory
    Status = Volume->Open(Root, &FileHandle, FullFilePath, EFI_FILE_MODE_READ, 0);
    if (EFI_ERROR(Status)) {
        Print(L"Failed to open file: %s\n", FullFilePath);
        return Status;
    }

    // Retrieve file info to know its size
    Status = FileHandle->GetInfo(FileHandle, &gEfiFileInfoGuid, &FileInfoSize, NULL);
    if (EFI_ERROR(Status)) {
        Print(L"Failed to get file info.\n");
        return Status;
    }

    // Allocate memory for file info and buffer
    FileInfo = AllocateZeroPool(FileInfoSize);
    if (FileInfo == NULL) {
        Print(L"Memory allocation for file info failed.\n");
        return EFI_OUT_OF_RESOURCES;
    }

    Status = FileHandle->GetInfo(FileHandle, &gEfiFileInfoGuid, &FileInfoSize, FileInfo);
    if (EFI_ERROR(Status)) {
        Print(L"Failed to retrieve file info.\n");
        return Status;
    }

    // Allocate buffer large enough to hold the file contents
    Buffer = AllocatePool(FileInfo->FileSize);
    if (Buffer == NULL) {
        Print(L"Buffer allocation failed.\n");
        return EFI_OUT_OF_RESOURCES;
    }

    // Read the file's contents into the buffer
    Status = FileHandle->Read(FileHandle, &ReadSize, Buffer);
    if (EFI_ERROR(Status)) {
        Print(L"Failed to read file.\n");
        return Status;
    }

    // Cast the buffer to a function pointer and jump to it
    VOID (*EntryPoint)(VOID) = (VOID (*)(VOID))Buffer;
    EntryPoint();  // Jump to the entry point in the loaded file

    // Clean up
    FileHandle->Close(FileHandle);
    FreePool(FileInfo);
    FreePool(Buffer);

    return EFI_SUCCESS;
}

// Kernel entry point
EFI_STATUS EFIAPI efi_main(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE *SystemTable) {
    EFI_STATUS Status;

    // Initialize the UEFI library
    InitializeLib(ImageHandle, SystemTable);

    // Call LoadAndJumpToFile with the file name of the binary to execute
    Status = LoadAndJumpToFile(ImageHandle, SystemTable, L"example.efi");

    if (EFI_ERROR(Status)) {
        Print(L"File loading or execution failed.\n");
    }

    return EFI_SUCCESS;
}
