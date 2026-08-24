import "DPI-C" function void c_dpi_write(input int unsigned addr, input int unsigned data);
import "DPI-C" function int  c_dpi_read_check(input int unsigned addr, input int unsigned actual_data);

class axi4_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(axi4_scoreboard)


  uvm_analysis_imp #(axi4_item, axi4_scoreboard) item_export;


  int match_count    = 0;
  int mismatch_count = 0;

  function new(string name = "axi4_scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_export = new("item_export", this);
  endfunction

  virtual function void write(axi4_item item);
    if (item.trans_type == WRITE) begin
      process_write(item);
    end else begin
      process_read(item);
    end
  endfunction


virtual function void process_write(axi4_item item);
    int bytes_per_beat = (1 << item.size); 
    
    for (int i = 0; i <= item.len; i++) begin
      bit [31:0] beat_addr = item.addr + (i * bytes_per_beat);
      c_dpi_write(beat_addr, item.data[i]);
    end
  endfunction

  virtual function void process_read(axi4_item item);
    int bytes_per_beat = (1 << item.size);
    
    for (int i = 0; i <= item.len; i++) begin
      bit [31:0] beat_addr = item.addr + (i * bytes_per_beat);
      if (!c_dpi_read_check(beat_addr, item.data[i])) begin
        mismatch_count++;
        `uvm_error("SCB_MISMATCH", $sformatf("DPI Data mismatch at Addr: 0x%0h | Beat: %0d", beat_addr, i))
      end else begin
        match_count++;
      end
    end
  endfunction

  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("SCB_REPORT", 
      $sformatf("Final Verification Results -> Matches: %0d | Mismatches: %0d", 
                match_count, mismatch_count), UVM_LOW)
  endfunction

endclass