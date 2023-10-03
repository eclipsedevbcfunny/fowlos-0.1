#include "../../include/allocation.h"
#include "../../include/ata.h"
#include "../../include/disk.h"
#include "../../include/fat32.h"
#include "../../include/idt.h"
#include "../../include/isr.h"
#include "../../include/kb.h"
#include "../../include/multiboot.h"
#include "../../include/rtc.h"
#include "../../include/shell.h"
#include "../../include/util.h"
#include "../../include/vga.h"

#include <stdint.h>

// Kernel entry file
// Copyright (C) 2023 Panagiotis

#define MEMORY_DETECTION_DRAFT 0
#define FAT32_READ_TEST 0
#define FAT32_DELETION_TEST 0

int kmain(uint32 magic, multiboot_info_t *mbi) {
  if (magic != MULTIBOOT_BOOTLOADER_MAGIC) {
    printf("invalid magic number!");
    asm("hlt");
  }

  /* Check bit 6 to see if we have a valid memory map */
  if (!(mbi->flags >> 6 & 0x1)) {
    printf("invalid memory map given by GRUB bootloader");
    asm("hlt");
  }

  clearScreen();

  string center = "                   ";
  printf("%s=========================================%s\n", center, center);
  printf("%s==     Cave-Like Operating System      ==%s\n", center, center);
  printf("%s==      Copyright MalwarePad 2023      ==%s\n", center, center);
  printf("%s=========================================%s\n\n", center, center);

  isr_install();
  init_memory(mbi);
  initiateFat32();

#if FAT32_DELETION_TEST
  int           clusterNum = 2;
  char         *filename = "UNTITLEDTXT";
  unsigned char rawArr[SECTOR_SIZE];
  while (1) {
    const int lba =
        fat.cluster_begin_lba + (clusterNum - 2) * fat.sectors_per_cluster;
    getDiskBytes(rawArr, lba, 1);

    for (int i = 0; i < (SECTOR_SIZE / 32); i++) {
      if (memcmp(rawArr + (32 * i), filename, 11) == 0) { // fatdir->filename
        pFAT32_Directory fatdir = (pFAT32_Directory)(&rawArr[32 * i]);
        printf("\n[dsearch] filename: %s\n", filename);
        printf("\n[dsearch] low=%d low1=%x low2=%x\n", fatdir->firstClusterLow,
               rawArr[32 * i + 26], rawArr[32 * i + 27]);
        for (int o = 0; o < 32; o++) {
          printf("%x ", rawArr[32 * i + o]);
        }
        printf("\n");

        printf("\nDeleting file %s!\n", filename);

        rawArr[32 * i] = FAT_DELETED;
        putDiskBytes(rawArr, lba, 1);
        printf("\n%s has been deleted!\n", filename);

        break;
      }
    }

    if (rawArr[SECTOR_SIZE - 32] != 0) {
      unsigned int nextCluster = getFatEntry(clusterNum);
      if (nextCluster == 0)
        break;
      clusterNum = nextCluster;
    } else
      break;
  }
#endif

#if FAT32_READ_TEST
  FAT32_Directory dir;
  if (!openFile(&dir, "/ab.txt"))
    printf("No such file can be found!\n");

  char *contents = readFileContents(&dir);
  printf("%s\n", contents);

  // fileReaderTest();
#endif
#if MEMORY_DETECTION_DRAFT
  printf("[+] Memory detection:");
#endif

#if MEMORY_DETECTION_DRAFT
  /* Loop through the memory map and display the values */
  for (int i = 0; i < mbi->mmap_length; i += sizeof(multiboot_memory_map_t)) {
    multiboot_memory_map_t *mmmt =
        (multiboot_memory_map_t *)(mbi->mmap_addr + i);
    // if (mmmt->type == MULTIBOOT_MEMORY_AVAILABLE)
    printf("\n    [+] Start Addr: %lx | Length: %lx | Size: "
           "%x | Type: %x",
           mmmt->addr, mmmt->len, mmmt->size, mmmt->type);
  }
  printf("\n");
#endif

  printf("\n");

  // findFile("/BOOT       /GRUB       /KERNEL  BIN");
  // findFile("/UNTITLEDLOL/UNTITLEDTXT");
  // findFile("/UNTITLEDTXT");
  // string out;
  // int    ret = followConventionalDirectoryLoop(out, "/hahalol/yes", 2);
  // printf("[%d] %d %s \n", ret, strlength(out), out);

  // printf("\nWelcome to cavOS! The OS that reminds you of how good computers
  // \nwere back then.. Anyway, just execute any command you want\n'help' is
  // your friend :)\n\nNote that this program comes with ABSOLUTELY NO
  // WARRANTY.\n");

  // string str = formatToShort8_3Format("grt.txt");
  // printf("%s [%d]", str, strlength(str));

  // ! this is my testing land lol

  /*printf("writing 0...\r\n");
  char bwrite[512];
  for(i = 0; i < 512; i++)
  {
      bwrite[i] = 0x0;
  }
  write_sectors_ATA_PIO(0x0, 2, bwrite);


  printf("reading...\r\n");
  read_sectors_ATA_PIO(target, 0x0, 1);

  i = 0;
  while(i < 128)
  {
      printf("%x ", target[i] & 0xFF);
      printf("%x ", (target[i] >> 8) & 0xFF);
      i++;
  }
  printf("\n");*/

  launch_shell(0, mbi);
}
