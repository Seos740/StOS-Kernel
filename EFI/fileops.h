#ifndef FILE_OPS_H
#define FILE_OPS_H

#include <efi.h>
#include <efilib.h>

// Include your existing .c scripts directly here
#include "FileOp.c"
#include "OpenFile.c"

// i could declare the functions here as well, although including the .c files will already make them available. (just do it in case);
EFI_STATUS LoadAndJumpToFile(IN EFI_HANDLE ImageHandle, IN EFI_SYSTEM_TABLE *SystemTable, IN CHAR16 *FileName);
EFI_STATUS OpenFile(IN EFI_FILE_PROTOCOL *RootDir, IN CHAR16 *FileName, OUT EFI_FILE_PROTOCOL **FileHandle);

#endif // FILE_OPS_H
