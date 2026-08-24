#include <iostream>
#include <unordered_map>
#include <queue>
#include <cstdint>
#include "svdpi.h"

static std::unordered_map<unsigned int, unsigned int> ref_memory;

extern "C" {

  // Write Logic: 
  DPI_DLLESPEC void c_dpi_write(unsigned int addr, unsigned int data) {
      ref_memory[addr] = data;
  }

  // Read Logic:
  DPI_DLLESPEC int c_dpi_read_check(unsigned int addr, unsigned int actual_data) {
      

      if (ref_memory.find(addr) != ref_memory.end()) {
          
          unsigned int expected_data = ref_memory[addr];
          

          if (expected_data == actual_data) {
              return 1; 
          } else {
              std::cout << "[C++ SCB ERROR] Mismatch at Addr 0x" << std::hex << addr 
                        << " | Expected: 0x" << expected_data 
                        << " | Actual: 0x" << actual_data << std::dec << std::endl;
              return 0;
          }
      } 
      else {

          std::cout << "[C++ SCB WARNING] Read from uninitialized Addr 0x" 
                    << std::hex << addr << std::dec << std::endl;

          return 0; 
      }
  }
}