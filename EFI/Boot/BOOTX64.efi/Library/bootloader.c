#include <efi.h>              // Includes the UEFI API header that defines UEFI data structures and functions
#include <efilib.h>           // Includes a helper library for easier UEFI programming

// Load the kernel into memory
EFI_STATUS LoadKernel(EFI_FILE_HANDLE Volume, VOID **KernelBuffer, UINTN *KernelSize) {
    EFI_STATUS Status;                    // Variable to store the status of operations
    EFI_FILE_HANDLE KernelFile;           // File handle for the kernel file
    EFI_FILE_INFO *FileInfo;              // Pointer to store file information (like size)
    UINTN FileInfoSize = 0;               // Size of the file information structure (initially 0)
    UINTN ReadSize;                       // Variable to store the actual number of bytes read from the file
    
    // Open the kernel file located at /EFI/StOS/kernel.bin in read mode
    Status = Volume->Open(Volume, &KernelFile, L"/EFI/StOS/kernel.bin", EFI_FILE_MODE_READ, 0);
    if (EFI_ERROR(Status)) {              // If opening the file fails
        Print(L"Failed to open kernel file.\n");  // Print error message
        return Status;                    // Return the error status
    }

    // Get the size of the kernel file (necessary for memory allocation later)
    Status = KernelFile->GetInfo(KernelFile, &gEfiFileInfoGuid, &FileInfoSize, NULL);
    if (EFI_ERROR(Status)) {              // If getting file info fails
        Print(L"Failed to get kernel file info.\n");  // Print error message
        return Status;                    // Return the error status
    }

    // Allocate memory for the file information structure based on the file size
    FileInfo = AllocatePool(FileInfoSize);
    if (FileInfo == NULL) {               // If memory allocation for file info fails
        Print(L"Failed to allocate memory for file info.\n");  // Print error message
        return EFI_OUT_OF_RESOURCES;      // Return out of resources error
    }

    // Retrieve the actual file information (such as file size) into the allocated memory
    Status = KernelFile->GetInfo(KernelFile, &gEfiFileInfoGuid, &FileInfoSize, FileInfo);
    if (EFI_ERROR(Status)) {              // If retrieving file info fails
        Print(L"Failed to get kernel file info.\n");  // Print error message
        FreePool(FileInfo);                // Free the allocated memory for file info
        return Status;                     // Return the error status
    }

    // Get the file size from the FileInfo structure and store it in KernelSize
    *KernelSize = FileInfo->FileSize;
    FreePool(FileInfo);                   // Free the allocated memory for file info

    // Allocate memory to load the kernel file based on its size
    Status = gBS->AllocatePool(EfiLoaderData, *KernelSize, KernelBuffer);
    if (EFI_ERROR(Status)) {              // If memory allocation for the kernel fails
        Print(L"Failed to allocate memory for the kernel.\n");  // Print error message
        return Status;                    // Return the error status
    }

    // Read the kernel file into the allocated memory
    Status = KernelFile->Read(KernelFile, &ReadSize, *KernelBuffer);
    if (EFI_ERROR(Status) || ReadSize != *KernelSize) {  // If reading fails or size doesn't match
        Print(L"Failed to read the kernel file into memory.\n");  // Print error message
        FreePool(*KernelBuffer);         // Free the allocated memory for the kernel buffer
        return Status;                   // Return the error status
    }

    Print(L"Kernel loaded into memory at address: %lx\n", *KernelBuffer); // Print address where the kernel is loaded

    // Close the kernel file after reading it
    KernelFile->Close(KernelFile);

    return EFI_SUCCESS;                  // Return success status
}

// Main entry point of the bootloader
EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    EFI_STATUS Status;                   // Variable to store the status of operations
    EFI_FILE_IO_INTERFACE *FileIO;       // Pointer to the file I/O protocol interface
    EFI_FILE_HANDLE Volume;              // File handle for the volume (file system)
    VOID *KernelBuffer = NULL;           // Pointer to store the kernel data loaded into memory
    UINTN KernelSize = 0;                // Variable to store the size of the kernel

    // Initialize the UEFI environment (prints some system info)
    InitializeLib(ImageHandle, SystemTable);
    Print(L"Hello, StOS Bootloader!\n");  // Print greeting message

    // Allocate 4 KiB of memory for any temporary buffers
    VOID *Buffer;
    UINTN Size = 4096;                   // Set the size to 4 KiB
    Status = SystemTable->BootServices->AllocatePool(EfiLoaderData, Size, &Buffer);
    if (EFI_ERROR(Status)) {             // If memory allocation fails
        Print(L"Failed to allocate 4 KiB memory.\n");  // Print error message
        return Status;                   // Return the error status
    }
    Print(L"Allocated 4 KiB at address: %lx\n", Buffer);  // Print address of the allocated buffer

    // Variables for retrieving and processing the memory map
    UINTN MapSize = 0, MapKey, DescSize;
    UINT32 DescVer;
    EFI_MEMORY_DESCRIPTOR *MemMap = NULL;

    // Get the initial memory map size
    Status = SystemTable->BootServices->GetMemoryMap(&MapSize, MemMap, &MapKey, &DescSize, &DescVer);
    if (EFI_ERROR(Status)) {             // If retrieving the memory map size fails
        Print(L"Failed to get memory map size.\n");  // Print error message
        return Status;                   // Return the error status
    }

    // Allocate memory for the memory map structure
    Status = SystemTable->BootServices->AllocatePool(EfiLoaderData, MapSize, (VOID **)&MemMap);
    if (EFI_ERROR(Status)) {             // If memory allocation for the memory map fails
        Print(L"Failed to allocate memory for memory map.\n");  // Print error message
        return Status;                   // Return the error status
    }

    // Retrieve the actual memory map
    Status = SystemTable->BootServices->GetMemoryMap(&MapSize, MemMap, &MapKey, &DescSize, &DescVer);
    if (EFI_ERROR(Status)) {             // If retrieving the memory map fails
        Print(L"Failed to get memory map.\n");  // Print error message
        return Status;                   // Return the error status
    }

    // Exit Boot Services (necessary to give control to the OS)
    Status = SystemTable->BootServices->ExitBootServices(ImageHandle, MapKey);
    if (EFI_ERROR(Status)) {             // If exiting boot services fails
        Print(L"Failed to exit boot services.\n");  // Print error message
        return Status;                   // Return the error status
    }

    // Locate the Simple File System protocol, used to access file systems
    Status = SystemTable->BootServices->LocateProtocol(&gEfiSimpleFileSystemProtocolGuid, NULL, (VOID **)&FileIO);
    if (EFI_ERROR(Status)) {             // If locating the file system protocol fails
        Print(L"Failed to locate the Simple File System protocol.\n");  // Print error message
        return Status;                   // Return the error status
    }

    // Open the file system volume (the EFI System Partition)
    Status = FileIO->OpenVolume(FileIO, &Volume);
    if (EFI_ERROR(Status)) {             // If opening the volume fails
        Print(L"Failed to open volume.\n");  // Print error message
        return Status;                   // Return the error status
    }

    // Load the kernel into memory using the LoadKernel function
    Status = LoadKernel(Volume, &KernelBuffer, &KernelSize);
    if (EFI_ERROR(Status)) {             // If loading the kernel fails
        Print(L"Failed to load kernel.\n");  // Print error message
        return Status;                   // Return the error status
    }

    // Exit boot services again after loading the kernel (necessary for kernel execution)
    Status = SystemTable->BootServices->ExitBootServices(ImageHandle, MapKey);
    if (EFI_ERROR(Status)) {             // If exiting boot services fails
        Print(L"Failed to exit boot services.\n");  // Print error message
        return Status;                   // Return the error status
    }

    // Jump to the kernel's entry point, assuming it's located at KernelBuffer
    ((void (*)(void))KernelBuffer)();    // Cast the kernel buffer to a function pointer and call it

    // If necessary, return from the main function (shouldn't reach here if jumping to kernel)
    return EFI_SUCCESS;                  // Return success status
}
