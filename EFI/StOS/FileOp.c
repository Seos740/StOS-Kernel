#include <efi.h>
#include <efilib.h>

// Function to read a file from a given directory in UEFI
EFI_STATUS ReadFileContents(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE *SystemTable, IN CHAR16 *Directory, IN CHAR16 *FileName) {
    EFI_STATUS Status;
    EFI_SIMPLE_FILE_SYSTEM_PROTOCOL *SimpleFileSystem = NULL;
    EFI_FILE_IO_INTERFACE *Volume = NULL;
    EFI_FILE *Root = NULL;
    EFI_FILE *FileHandle = NULL;
    EFI_FILE_INFO *FileInfo = NULL;
    UINTN FileInfoSize = 0;
    CHAR8 *Buffer = NULL;
    UINTN ReadSize = 0;
    CHAR16 FullFilePath[512];

    // Initialize UEFI library
    InitializeLib(ImageHandle, SystemTable);

    // Concatenate the directory and file name to form the full path
    StrCpy(FullFilePath, Directory);
    StrCat(FullFilePath, FileName);

    // Locate Simple File System Protocol
    Status = gBS->LocateHandleBuffer(ByProtocol, &gEfiSimpleFileSystemProtocolGuid, NULL, &HandleCount, &HandleBuffer);
    if (EFI_ERROR(Status)) {
        Print(L"Failed to locate Simple File System Protocol.\n");
        return Status;
    }

    // Open the volume (partition)
    Status = gBS->HandleProtocol(HandleBuffer[0], &gEfiSimpleFileSystemProtocolGuid, (VOID **)&SimpleFileSystem);
    if (EFI_ERROR(Status)) {
        Print(L"Failed to get Simple File System Protocol.\n");
        return Status;
    }

    // Open the volume to access files
    Status = SimpleFileSystem->OpenVolume(SimpleFileSystem, &Volume);
    if (EFI_ERROR(Status)) {
        Print(L"Failed to open volume.\n");
        return Status;
    }

    // Open the root directory
    Status = Volume->OpenVolume(Volume, &Root);
    if (EFI_ERROR(Status)) {
        Print(L"Failed to open root directory.\n");
        return Status;
    }

    // Open the specific file from the directory
    Status = Root->Open(Root, &FileHandle, FullFilePath, EFI_FILE_MODE_READ, 0);
    if (EFI_ERROR(Status)) {
        Print(L"Failed to open the file %s\n", FullFilePath);
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

    // Allocate a buffer large enough to hold the file contents
    Buffer = AllocatePool(FileInfo->FileSize);
    if (Buffer == NULL) {
        Print(L"Buffer allocation failed.\n");
        return EFI_OUT_OF_RESOURCES;
    }

    // Read the file's contents
    Status = FileHandle->Read(FileHandle, &ReadSize, Buffer);
    if (EFI_ERROR(Status)) {
        Print(L"Failed to read file.\n");
        return Status;
    }

    // Print the file contents (just for demonstration purposes)
    Print(L"File contents: \n");
    for (UINTN i = 0; i < ReadSize; ++i) {
        Print(L"%c", Buffer[i]);
    }

    // Clean up
    FreePool(Buffer);
    FileHandle->Close(FileHandle);
    FreePool(FileInfo);

    return EFI_SUCCESS;
}

// Kernel entry point
EFI_STATUS EFIAPI efi_main(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE *SystemTable) {
    EFI_STATUS Status;

    // Initialize the UEFI library
    InitializeLib(ImageHandle, SystemTable);

    // Call ReadFileContents function with a directory and file name
    Status = ReadFileContents(ImageHandle, SystemTable, L"\\", L"example.txt");

    if (EFI_ERROR(Status)) {
        Print(L"File reading failed.\n");
    }

    return EFI_SUCCESS;
}
