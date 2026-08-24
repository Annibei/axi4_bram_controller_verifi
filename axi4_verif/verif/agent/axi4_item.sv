class axi4_item  #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32,
    parameter ID_WIDTH   = 4
  ) extends uvm_sequence_item;

function new(string name = "axi4_item");
  super.new(name);
endfunction

//FIELDS
  rand axi_trans_e                 trans_type;
  rand bit [ID_WIDTH-1:0]          id;
  rand bit [ADDR_WIDTH-1:0]        addr;
  rand bit [7:0]                   len;
  rand bit [2:0]                   size;
  rand axi_burst_e                 burst;
  rand bit [DATA_WIDTH-1:0]        data[];
  rand bit [(DATA_WIDTH/8)-1:0]    wstrb[];
       axi_resp_e                  resp;

//CONSTRAINTS
constraint c_array_sizes {
  data.size()  == len + 1;
  wstrb.size() == len + 1;
}

constraint c_valid_size {
  (1 << size) <= (DATA_WIDTH / 8);
}

constraint c_4k_boundary {
  ((addr & 12'hFFF) + ((len + 1) * (1 << size))) <= 4096;
}

constraint c_burst_rules {
  (burst == WRAP) -> len inside {1, 3, 7, 15};
  
  (burst == FIXED) -> len <= 15;
}

constraint c_aligned_addr {
  soft (addr % (1 << size)) == 0;
}

//MACROS
  `uvm_object_utils_begin(axi4_item)  
    `uvm_field_enum(axi_trans_e, trans_type, UVM_ALL_ON)
    `uvm_field_int(id,  UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(addr,   UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(len,  UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_int(size,  UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_enum(axi_burst_e, burst, UVM_ALL_ON | UVM_NOCOMPARE)
    `uvm_field_array_int(data, UVM_ALL_ON)
    `uvm_field_array_int(wstrb, UVM_ALL_ON)
  `uvm_object_utils_end


//FUNCTIONS
virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
  axi4_item #(ADDR_WIDTH, DATA_WIDTH, ID_WIDTH) rhs_;
  bit match = 1;

  if (!$cast(rhs_, rhs)) begin
     `uvm_fatal("COMP_FATAL", "Compared non-AXI4 item.")
     return 0;
  end

  if(this.data.size() != rhs_.data.size()) begin
    return 0;
  end
  for (int i = 0; i < this.data.size(); i++) begin
    if (this.data[i] != rhs_.data[i]) begin
      return 0;
    end
  end

        match &= (this.addr === rhs_.addr);
        match &= (this.len === rhs_.len);
        match &= (this.size === rhs_.size);
    return match;
endfunction

virtual function void do_copy(uvm_object rhs);
  axi4_item rhs_;
  super.do_copy(rhs);
  
  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("DO_COPY", "Cast failed. Tried to copy a non-axi4_item object.")
  end

  this.trans_type = rhs_.trans_type;
  this.id = rhs_.id;
  this.addr = rhs_.addr;
  this.len = rhs_.len;
  this.size = rhs_.size;
  this.burst = rhs_.burst;
  this.data = rhs_.data;
  this.wstrb = rhs_.wstrb;
  this.resp = rhs_.resp;
endfunction

virtual function string convert2string();
string s;
s = $sformatf("TYPE=%s ID=0x%0h ADDR=0x%0h LEN=%0d SIZE=%0d BURST=%s RESP=%s",
                trans_type.name(), id, addr, len, size, burst.name(), resp.name());
return s;
endfunction

virtual function void do_print(uvm_printer printer);
  super.do_print(printer);

  printer.print_generic("AXI4_ITEM", "axi4_item", -1, this.convert2string());
endfunction

endclass
