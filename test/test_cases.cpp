#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include <sstream>
#include <set>
#include <bitset>
#include <iterator>
#include <iomanip> 
#include <cassert>
#include <algorithm>
using namespace std;

string reset_vector = "10111111110000000000000000000000";
//instructions to test
set<string>I_TYPE{"addiu","andi","beq","bgez","bgezal","bgtz","blez","bltz","bltzal",
    "bne","lb","lbu","lh","lhu","lui","lw","ori","sb","sh","slti","sltiu","sw","xori"};
set<string>R_TYPE{"addu","and","div","divu","jr","jalr","mfhi","mthi","mflo","mtlo","mult","multu",
    "or","sll","sllv","slt","slti","sltiu","sltu","sra","srav","srl","srlv","subu","xor"};
set<string>J_TYPE{"j", "jal"};
string bintohex(const string &s){
    string out;
    for(uint i = 0; i < s.size(); i += 4){
        int8_t n = 0;
        for(uint j = i; j < i + 4; ++j){
            n <<= 1;
            if(s[j] == '1')
                n |= 1;
        }

        if(n<=9)
            out.push_back('0' + n);
        else
            out.push_back('A' + n - 10);
    }

    return out;
}

string registerCode( string &r){
    r.erase(remove(r.begin(), r.end(), ','), r.end());
    if(r == "$0" || r == "$zero")
        return "00000";
    if(r == "$1" || r == "$at")
        return "00001";
    if(r == "$2" || r == "$v0")
        return "00010";
    if(r == "$3" || r == "$v1")
        return "00011";
    if(r == "$4" || r == "$a0")
        return "00100";
    if(r == "$5" || r == "$a1")
        return "00101";
    if(r == "$6" || r == "$a2")
        return "00110";
    if(r == "$7" || r == "$a3")
        return "00111";
    if(r == "$8" || r == "$t0")
        return "01000";
    if(r == "$9" || r == "$t1")
        return "01001";
    if(r == "$10" || r == "$t2")
        return "01010";
    if(r == "$11" || r == "$t3")
        return "01011";
    if(r == "$12" || r == "$t4")
        return "01100";
    if(r == "$13" || r == "$t5")
        return "01101";
    if(r == "$14" || r == "$t6")
        return "01110";
    if(r == "$15" || r == "$t7")
        return "01111";

    if(r == "$16" || r == "$s0")
        return "10000";
    if(r == "$17" || r == "$s1")
        return "10001";
    if(r == "$18" || r == "$s2")
        return "10010";
    if(r == "$19" || r == "$s3")
        return "10011";
    if(r == "$20" || r == "$s4")
        return "10100";
    if(r == "$21" || r == "$s5")
        return "10101";
    if(r == "$22" || r == "$s6")
        return "10110";
    if(r == "$23" || r == "$s7")
        return "10111";
    if(r == "$24" || r == "$t8")
        return "11000";
    if(r == "$25" || r == "$t9")
        return "11001";
    if(r == "$26" || r == "$k0")
        return "11010";
    if(r == "$27" || r == "$k1")
        return "11011";
    if(r == "$28" || r == "$gp")
        return "11100";
    if(r == "$29" || r == "$sp")
        return "11101";
    if(r == "$30" || r == "$fp")
        return "11110";
    else
        return "11111";
}




string I_TypeProcess(vector<string> &params){
    string opcode, Rs, Rt, imm;
    string temp;
    string imm_Rs;
    string op = params[0];
    // op rs rt imm
    if(op == "beq" || op == "bne"){
        Rs = registerCode(params[1]);
        Rt = registerCode(params[2]);
        //imm = signExtend(params[3]); //need some calculating here
        if(op == "beq")
            opcode = "000100";
        else if(op == "bne")
            opcode = "000101";
        else
            ;
    }
    //op rt rs imm
    else if(op == "addi" || op == "addiu" || op == "andi" || op == "ori" ||
            op == "xori" || op == "slti"  || op == "slti" || op == "sltiu"){
        Rt = registerCode(params[1]);
        Rs = registerCode(params[2]);
        int num = stoi(params[3]);
        if(op == "addi" || op == "slti" || op == "sltiu"|| op == "addiu"){
            bitset<16> y(num);
            imm = y.to_string<char,string::traits_type,string::allocator_type>();
        }else{ 
            //supposed to 0 extend
            bitset<16> y(num);
            imm = y.to_string<char,string::traits_type,string::allocator_type>();
        }

        if(op == "addi")
            opcode = "001000";
        else if(op == "addiu")
            opcode = "001001";
        else if(op == "andi")
            opcode = "001100";
        else if(op == "ori")
            opcode = "001101";
        else if(op == "xori")
            opcode = "001110";
        else if(op == "slti")
            opcode = "001010";
        else if(op == "sltiu")
            opcode = "001011";
        else
            ;
    }
     // op rt imm(rs)
    else if(op == "lw" || op == "sw" || op == "lb" || op == "lbu" || op == "lh" ||
            op == "lhu" || op == "sb" || op == "sb" || op == "sh"){
        Rt = registerCode(params[1]);
        //get the thing in the reg
        string reg = params[2];
        size_t spos = reg.find("(");
        size_t epos = reg.find(")");
        string reg_val = (reg).substr(spos+1, epos-spos-1);
        Rs = registerCode(reg_val);
        int imm_reg= stoi(reg.substr(0, spos));
        bitset<16> y(imm_reg);
        imm = y.to_string<char,string::traits_type,string::allocator_type>();

        if(op == "lw")
            opcode = "100011";
        else if(op == "sw")
            opcode = "101011";
        else if(op == "lb")
            opcode = "100000";
        else if(op == "lbu")
            opcode = "100100";
        else if(op == "lh")
            opcode = "100001";
        else if(op == "lhu")
            opcode = "100101";
        else if(op == "sb")
            opcode = "101000";
        else if(op == "sh")
            opcode = "101001";
    }

    // op rt imm
    else if(op == "lui"){
        Rt = registerCode(params[1]);

        Rs = "00000";

        bitset<16> y(stoi(params[2]));
        imm = y.to_string<char,string::traits_type,string::allocator_type>();

        opcode = "001111";
    }

    // op rs imm
    else if(op == "blez" || op == "bltz" || op == "bgtz" || op == "bgez"){
        Rs = registerCode(params[1]);
        //get address for jump, add to counter
        bitset<16> y(stoi(params[2]));
        imm = y.to_string<char,string::traits_type,string::allocator_type>();

        if(op == "bgez"){
            opcode = "000001";
            Rt = "00001";
        }
        else if(op == "bgtz"){
            opcode = "000111";
            Rt = "00000";
        }
        else if(op == "blez"){
            opcode = "000110";
            Rt = "00000";
        }
        else if(op == "bltz"){
            opcode = "000001";
            Rt = "00000";
        }

        else
            ;
    }
    return(opcode+Rs+Rt+imm);
}
string R_TypeProcess(vector<string> &params){
    string op = params[0];
    string opcode="000000", Rt, Rd, Rs, shamt, funct;
    //op rd rt shamt
    if(op == "sll" || op == "srl" || op == "sra"){
        Rd = registerCode(params[1]);
        Rt = registerCode(params[2]);
        Rs = "00000";
        bitset<5> y(stoi(params[3]));
        shamt = y.to_string<char,string::traits_type,string::allocator_type>(); 
        if (op =="sll"){
            funct =  "000000"; 
        }else if(op == "srl"){
            funct ="000010";
        }else if(op == "sra"){
            funct ="000011";
        }
    }
    //op rd rt rs
    else if (op == "sllv" || op == "srlv" || op == "srav"){
        Rd = registerCode(params[1]);
        Rt = registerCode(params[2]);
        Rs = registerCode(params[3]);
        shamt ="00000"; 
        if (op =="sllv"){
            funct =  "000100"; 
        }else if(op == "srlv"){
            funct ="000110";
        }else if(op == "srav"){
            funct ="000111";
        }
    }
    //op rd rs
    else if (op == "jalr"){
        Rd = registerCode(params[1]);
        Rt = "00000";
        Rs = registerCode(params[2]);
        shamt ="00000";
        funct = "001001";
    }
    //op rs rt
    else if (op == "mult" || op == "multu" || op == "div" ||op == "divu"){
        Rd = "00000";
        Rt = registerCode(params[2]);
        Rs = registerCode(params[1]);
        shamt ="00000";
        if (op =="mult"){
            funct =  "011000"; 
        }else if(op == "multu"){
            funct ="011001";
        }else if(op == "div"){
            funct ="011010";
        }else if(op == "divu"){
            funct ="011011";
        }
    }
    //op rd rs rt
    else if (op == "add"||op == "addu" ||op == "sub"||op == "subu"||op == "and"||op == "or"||
    op == "xor" || op == "not"||op == "nor"||op == "slt"||op == "sltu"){
        Rd = registerCode(params[1]);
        Rt = registerCode(params[3]);
        Rs = registerCode(params[2]);
        shamt ="00000";
        if (op == "add"){
            funct = "100000";
        }else if (op == "addu"){
            funct = "100001";
        }else if(op == "sub"){
            funct = "100010";
        }else if (op == "subu"){
            funct = "100011";
        }else if(op == "and"){
            funct = "100100";
        }else if(op == "or"){
            funct = "100101";
        }else if (op == "xor"){
            funct = "100110";
        }else if(op == "slt"){
            funct = "101010";
        }else if (op == "sltu"){
            funct = "101011";
        }

    }
    //op rs
    else if (op=="jr" || op == "mthi" || op == "mtlo"){
        Rs=registerCode(params[1]);
        Rd = "00000";
        Rt = "00000";
        shamt = "00000";
        if (op == "jr")
            funct = "001000";
        else if (op == "mthi")
            funct = "010001";
        else if (op == "mtlo")
            funct = "010011";
    }
    //op rd
    else if(op == "mfhi" || op == "mflo"){
        Rd=registerCode(params[1]);
        Rs = "00000";
        Rt = "00000";
        shamt = "00000";
        if (op == "mfhi")
            funct = "010000";
        else if (op == "mflo")
            funct = "010010";
    }
    return (opcode+Rs+Rt+Rd+shamt+funct);

}

string J_TypeProcess(vector<string> &params){
    string op = params[0];
    string opcode, target;
    int temp;
    if(op == "j")
        opcode = "000010";
    else if(op == "jal")
        opcode = "000011";
    bitset<26> y(stoi(params[1])>>2);
    target = y.to_string<char,string::traits_type,string::allocator_type>();
    return (opcode+target);

}


void run_test(string inpf, string outf, string compf){ //input, output, copy of expected out
    string memloc;
    string data;
    string line;
    int temp=0;
    //memloc = reset_vector;
    ifstream infile; 
    infile.open(inpf); 
    vector<string>lines;
    if (infile.is_open()) {
        string line;
        while (getline(infile, line)) {
            lines.push_back(line.c_str());
        }
    infile.close();
    }
    ofstream outfile; 
    outfile.open(outf); 
    ofstream compfile; 
    compfile.open(compf); 
    for (int i = 0;i<lines.size();i++){
        string line = lines[i];
        if (line.find('.') == string::npos&&line.find(':') == string::npos){ //ignore the things with dots and location for now
            istringstream iss(line);//split by spaces
            vector<string> params((istream_iterator<string>(iss)),istream_iterator<string>());
            string binary_string;
            if (I_TYPE.find(params[0]) != I_TYPE.end()){
                binary_string = I_TypeProcess(params);
            }else if (R_TYPE.find(params[0]) != R_TYPE.end()){
                binary_string = R_TypeProcess(params);
            }else if (J_TYPE.find(params[0]) != J_TYPE.end()){
                binary_string = J_TypeProcess(params);
            }else{
                binary_string = "00000000000000000000000000000000"; //no op
            }
            string hex_string = bintohex(binary_string);
            outfile <<hex_string<<endl;

            if (params[1]=="$v0"){ ///how to track the output of this
                compfile<<temp<<endl;
            }

        }
    }
    outfile.close();
    compfile.close();
}
int main(){
    run_test("0-cases/sw_1.txt", "1-binary/sw_1.txt", "4-reference/sw_1.txt");
}