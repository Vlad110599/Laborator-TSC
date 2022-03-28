/***********************************************************************
 * A SystemVerilog testbench for an instruction register; This file
 * contains the interface to connect the testbench to the design
 **********************************************************************/
interface tb_ifc (input logic clk);
  //timeunit 1ns/1ns;

  // user-defined types are defined in instr_register_pkg.sv
  import instr_register_pkg::*;

  // ADD CODE TO DECLARE THE INTERFACE SIGNALS
  logic          load_en;
  logic          reset_n;
  opcode_t       opcode;
  operand_t      operand_a, operand_b;
  address_t      write_pointer, read_pointer;
  instruction_t  instruction_word;

  clocking cb @(clk);
    //default input #25ns output #10ns;
    input instruction_word;
    output load_en, reset_n, opcode, operand_a, operand_b, write_pointer, read_pointer;
  endclocking  

  modport TB (
    clocking cb
  );




endinterface: tb_ifc

