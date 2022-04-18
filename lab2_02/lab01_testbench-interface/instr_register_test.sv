/***********************************************************************
 * A SystemVerilog testbench for an instruction register.
 * The course labs will convert this to an object-oriented testbench
 * with constrained random test generation, functional coverage, and
 * a scoreboard for self-verification.
 **********************************************************************/
import instr_register_pkg::*;

class First_test;
    virtual tb_ifc.TB interfata_lab1;
    //int seed;
    parameter gen_nr_operation = 100000;

    covergroup my_coverGroup;
      OP_A_COVER: coverpoint interfata_lab1.cb.operand_a {
        bins op_a_neg_values[] = {[-15:-1]};
        bins op_a_zero = {0};
        bins op_a_pos_values[] = {[1:15]};
      }
      OP_B_COVER: coverpoint interfata_lab1.cb.operand_b {
        bins op_b_zero = {0};
        bins op_b_values[] = {[1:15]};
      }
      OPCODE_COVER: coverpoint interfata_lab1.cb.opcode {
        bins opcode_values[] = {[0:7]};
      }
      RESULT_COVER: coverpoint interfata_lab1.cb.instruction_word.res {
        bins result_neg_values[] = {[-225:-1]};
        bins result_zero = {0};
        bins result_pos_values[] = {[1:225]};
      }
      //Tema: de scris coverpoint pentru rezultat
    endgroup  

    function new(virtual tb_ifc.TB interfata);
      interfata_lab1 = interfata;
      my_coverGroup = new();
     // seed = 555;
    endfunction : new 

    task run ();
    $display("\n\n***********************************************************");
    $display(    "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(    "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(    "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(    "***********************************************************");
    $display(    "***  FIRST HEADER *****************************************");


    $display("\nReseting the instruction register...");
    interfata_lab1.cb.write_pointer  <= 5'h00;         // initialize write pointer
    interfata_lab1.cb.read_pointer   <= 5'h1F;         // initialize read pointer
    interfata_lab1.cb.load_en        <= 1'b0;          // initialize load control line
    interfata_lab1.cb.reset_n       <= 1'b0;          // assert reset_n (active low)
    repeat (2) @(posedge interfata_lab1.cb) ;     // hold in reset for 2 clock cycles
    interfata_lab1.cb.reset_n        <= 1'b1;          // deassert reset_n (active low)

    $display("\nWriting values to register stack...");
    @(posedge interfata_lab1.cb) interfata_lab1.cb.load_en <= 1'b1;  // enable writing to register
    repeat (gen_nr_operation) begin
      @(posedge interfata_lab1.cb) randomize_transaction; //o functie are timp de simulare zero.
      @(negedge interfata_lab1.cb) print_transaction;
      my_coverGroup.sample();
    end
    @(posedge interfata_lab1.cb) interfata_lab1.cb.load_en <= 1'b0;  // turn-off writing to register

    // read back and display same three register locations
    $display("\nReading back the same register locations written...");
    for (int i=0; i<=(gen_nr_operation - 1); i++) begin
      // later labs will replace this loop with iterating through a
      // scoreboard to determine which addresses were written and
      // the expected values to be read back
      @(posedge interfata_lab1.cb) interfata_lab1.cb.read_pointer <= i;
      @(negedge interfata_lab1.cb) print_results;
      my_coverGroup.sample();
    end

    @(posedge interfata_lab1.cb) ;
    $display("\n***********************************************************");
    $display(  "***  THIS IS NOT A SELF-CHECKING TESTBENCH (YET).  YOU  ***");
    $display(  "***  NEED TO VISUALLY VERIFY THAT THE OUTPUT VALUES     ***");
    $display(  "***  MATCH THE INPUT VALUES FOR EACH REGISTER LOCATION  ***");
    $display(  "***********************************************************\n");
    $finish;
  //end
  endtask

  function void randomize_transaction;
    // A later lab will replace this function with SystemVerilog
    // constrained random values
    //
    // The stactic temp variable is required in order to write to fixed
    // addresses of 0, 1 and 2.  This will be replaceed with randomizeed
    // write_pointer values in a later lab

    //Random e stabila pe thread, urandom e stabila pe clasa.
    //
    static int temp = 0;
    // interfata_lab1.cb.operand_a     <= $random(seed)%16;                 // between -15 and 15
    // interfata_lab1.cb.operand_b     <= $unsigned($random)%16;            // between 0 and 15
    // interfata_lab1.cb.opcode        <= opcode_t'($unsigned($random)%8);  // between 0 and 7, cast to opcode_t type
    interfata_lab1.cb.operand_a     <= $signed($urandom())%16;                 // between -15 and 15
    interfata_lab1.cb.operand_b     <= $unsigned($urandom)%16;            // between 0 and 15
    interfata_lab1.cb.opcode        <= opcode_t'($unsigned($urandom)%8);  // between 0 and 7, cast to opcode_t type
    interfata_lab1.cb.write_pointer <= temp++;
  endfunction: randomize_transaction

  function void print_transaction;
    $display("Writing to register location %0d: ", interfata_lab1.cb.write_pointer);
    $display("  opcode = %0d (%s)", interfata_lab1.cb.opcode, interfata_lab1.cb.opcode.name);
    $display("  operand_a = %0d",   interfata_lab1.cb.operand_a);
    $display("  operand_b = %0d\n", interfata_lab1.cb.operand_b);
    $display(" Print transaction, time: %0d ns ", $time());
  endfunction: print_transaction

  function void print_results;
    $display("Read from register location %0d: ", interfata_lab1.cb.read_pointer);
    $display("  opcode = %0d (%s)", interfata_lab1.cb.instruction_word.opc, interfata_lab1.cb.instruction_word.opc.name);
    $display("  operand_a = %0d",   interfata_lab1.cb.instruction_word.op_a);
    $display("  operand_b = %0d", interfata_lab1.cb.instruction_word.op_b);
    $display("  result = %0d\n", interfata_lab1.cb.instruction_word.res);
  endfunction: print_results

endclass : First_test

module instr_register_test(tb_ifc.TB interfata_lab1);
  // user-defined types are defined in instr_register_pkg.sv

  //timeunit 1ns/1ns;

  //int seed = 555; // reprezinta valoarea initiala cu care se va incepe randomizarea

  //tot fara initial begin, intra in clasa (functii, variabile interne, task-uri, etc..)
  //declarare interfata: virtual tb_ifc.TB nume;

  initial begin
     First_test test;
     test = new(interfata_lab1);
     //test.interfata_lab1 = interfata_lab1;
     test.run();
  end  
  //initial begin
  
endmodule: instr_register_test
