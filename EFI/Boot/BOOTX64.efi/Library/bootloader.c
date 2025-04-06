#include <efi.h>
#include <efilib.h>

EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    InitializeLib(ImageHandle, SystemTable);
    Print(L"Hello, StOS UEFI World!\n");
    return EFI_SUCCESS;
}

VOID *Buffer;
UTNTN Size = 4096;

SystemTable->BootServices->AllocatePool(EfiLoaderData, Size, &Buffer);
Print(L"Allocated 4 KiB at address: %lx\n", Buffer);

UINTN MapSize = 0, MapKey, DescSize;
UINT32 DescVer;
EFI_MEMORY_DESCRIPTOR *MemMap = NULL;

// Get memory map size
SystemTable->BootServices->GetMemoryMap(&MapSize, MemMap, &MapKey, &DescSize, &DescVer);

// Allocate memory for map
SystemTable->BootServices->AllocatePool(EfiLoaderData, MapSize, (VOID **)&MemMap);

// Get the map again with buffer
SystemTable->BootServices->GetMemoryMap(&MapSize, MemMap, &MapKey, &DescSize, &DescVer);

// Exit boot services
SystemTable->BootServices->ExitBootServices(ImageHandle, MapKey);


EFI_FILE_IO_INTERFACE *FileIO;
EFI_FILE_HANDLE Volume;
EFI_FILE_HANDLE File;

SystemTable->BootServices->LocateProtocol(&gEfiSimpleFileSystemProtocolGuid, NULL, (VOID **)&FileIO);
FileIO->OpenVolume(FileIO, &Volume);
Volume->Open(Volume, &File, L"/EFI/StOS/kernel_entry.c", EFI_FILE_MODE_READ, 0);
