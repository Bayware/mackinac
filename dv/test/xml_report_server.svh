//----------------------------------------------------------------------
//   Copyright 2012 Verilab Inc.
//   Gordon McGregor (gordon.mcgregor@verilab.com)
//
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------
//   Copyright 2015 MoriLab. modified
//   d.mori (twitter @morittyo)
//
//   Licensed under the Apache License, Version 2.0 ,too.
//
//   - UVM 1.1
//   - Jenkins 1.611
//     + JUnit Plugin 1.5
//----------------------------------------------------------------------

`ifndef __XML_REPORT_SERVER_SVH__
`define __XML_REPORT_SERVER_SVH__

import uvm_pkg::*;
`include "uvm_macros.svh"

class xml_report_server extends uvm_report_server;

  uvm_report_server old_report_server;
  uvm_report_global_server global_server;

  string test_name;
  string suite_name;
  string class_name;

  // This string holds all of the messages that have triggered a failure
  string all_error_messages;
  string all_error_details;

  integer logfile_handle;
  integer start_time;
  integer end_time;

  // characters that are invalid XML that have to be encoded
  string replacements[string] = '{ "<" : "&lt;",
                                   "&" : "&amp;",
                                   ">" : "&gt;",
                                   "'" : "&apos;",
                                   "\"": "&quot;"
                                 };

  /// constructor
  function new(string name,string log_filename = "",string suitename = "",string classname = "",string packagename = "");
    super.new();

    start_time = now_in_seconds();
    test_name = name;
    global_server = new();
    install_server();
    if(log_filename=="")begin
      $swrite(log_filename,"%s.xml",name);
    end
    if(suitename=="")begin
      suite_name = test_name;
    end else begin
      suite_name = suitename;
    end
    if((packagename=="") && (classname==""))begin
      class_name = test_name; 
    end else if (packagename=="") begin
      class_name = {classname,".",test_name};
    end else if (classname=="") begin
      class_name = {packagename,".",test_name};
    end else begin
      class_name = {packagename,".",classname};
    end
    logfile_handle = $fopen(log_filename, "w");
  endfunction

  /// replace the global server with this server
  function void install_server;
    old_report_server = global_server.get_server();
    global_server.set_server(this);
  endfunction

  /// Configure all components to use UVM_LOG actions to trigger XML capture
  /// has to be called after components have been instantiated (end of elaboration, run etc)
  function void enable_xml_logging(uvm_component base=null);
    uvm_root top;

    if (base == null) begin
      top = uvm_root::get();
      base = top;
    end

    base.set_report_default_file_hier(logfile_handle);
    base.set_report_severity_action_hier(UVM_INFO,    UVM_DISPLAY | UVM_LOG);
    base.set_report_severity_action_hier(UVM_WARNING, UVM_DISPLAY | UVM_LOG);
    base.set_report_severity_action_hier(UVM_ERROR,   UVM_DISPLAY | UVM_LOG | UVM_COUNT);
    base.set_report_severity_action_hier(UVM_FATAL,   UVM_DISPLAY | UVM_LOG | UVM_EXIT);
  endfunction

  /// Helper function to convert verbosity value to appropriate string, based on uvm_verbosity enum if an equivalent level
  function string convert_verbosity_to_string(int verbosity);
    uvm_verbosity l_verbosity;

    if ($cast(l_verbosity, verbosity)) begin
        convert_verbosity_to_string = l_verbosity.name();
    end else begin
        string l_str;
        l_str.itoa(verbosity);
        convert_verbosity_to_string = l_str;
    end
  endfunction

  /// Output JUnit XML header to log file
  function void report_header(UVM_FILE file = 0);
    string str;
    $swrite(str, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
    $swrite(str, "%s\n<testsuite%s>",str,{xla("name",suite_name)});
    f_display(file,str);
  endfunction

  /// Output JUnit XML closing tags to log file
  function void report_footer(UVM_FILE file = 0);
    integer result;
    integer elapsed_seconds;
    string elapsed_time_string;

    $fflush(file);
    result = $fseek(file, 0, 2);

    elapsed_seconds = end_time - start_time;
    $sformat(elapsed_time_string,"%0d",elapsed_seconds);

    if (test_passed()) begin
      f_display(file, xle_n("testcase"," ",{xla("classname",class_name),xla("name",test_name),xla("time",elapsed_time_string)}));
    end else begin
      f_display(file, xle_n("testcase",{xle("failure"," ",xla("message",all_error_messages)),xle("system-out",all_error_details)},{xla("classname",class_name),xla("name",test_name),xla("time",elapsed_time_string)}));
    end

    f_display(file, "</testsuite>");
  endfunction

  function bit test_passed();
     if ( (get_severity_count(UVM_ERROR)>0) || 
          (get_severity_count(UVM_FATAL)>0) || 
          (get_severity_count(UVM_WARNING)>0)) begin
       test_passed = 0;
     end else begin
       test_passed = 1;
     end
  endfunction

  /// tidy up logging and restore global report server
  function void summarize(UVM_FILE file = 0);
    end_time = now_in_seconds();
    report_header(logfile_handle);
    report_footer(logfile_handle);
    global_server.set_server(old_report_server);
    $fclose(logfile_handle);
    old_report_server.summarize(file);

    // Print out a nice Overall summary
    if (!test_passed()) begin
      f_display(file, "*****************************************************************************************");
      f_display(file, "************************************** TEST FAILED **************************************");
      f_display(file, "*****************************************************************************************");
    end else begin
      f_display(file, "*****************************************************************************************");
      f_display(file, "************************************** TEST PASSED **************************************");
      f_display(file, "*****************************************************************************************");
    end
  endfunction

  /// Processes the message's actions.
  virtual function void process_report(
    uvm_severity severity,
    string name,
    string id,
    string message,
    uvm_action action,
    UVM_FILE file,
    string filename,
    int line,
    string composed_message,
    int verbosity_level,
    uvm_report_object client
    );
    // update counts
    incr_severity_count(severity);
    incr_id_count(id);

    if(action & UVM_DISPLAY) begin
      $display("%s",composed_message);
    end

    // Keep track of all the error messages
    compose_xml_message(severity, verbosity_level, name, id, message, filename, line);

    if(action & UVM_LOG) begin
      // We aren't requiring that the UVM_LOG action be set, nor are we supporting uvm specific logging to a specific UVM Log file
    end

    if(action & UVM_EXIT) client.die();

    if(action & UVM_COUNT) begin
      if(get_max_quit_count() != 0) begin
        incr_quit_count();
        if(is_quit_count_reached()) begin
          client.die();
        end
      end
    end

    if (action & UVM_STOP) $stop;

  endfunction

  /// Given an unencoded input string, replaces illegal characters for XML data format
  function string sanitize(string data);

    for(int i = data.len()-1; i >= 0; i--) begin
      if (replacements.exists(data[i])) begin
          data = {data.substr(0,i-1), replacements[data[i]], data.substr(i+1, data.len()-1)};
      end
    end
    return data;
  endfunction : sanitize

  /// XML Attribute
  /// Generate an XML attribute ( tag = "data" )
  function string xla(string tag, string data);
    xla="";
    if (data != "") begin
      xla = {" ", tag, "=\"", sanitize(data), "\" "};
    end
  endfunction

  /// XML Element (data sanitized)
  /// Generate an XML element ( <tag attributes>data</tag> )
  function string xle(string tag, string data, string attributes="");
    xle = xle_n(tag,sanitize(data),attributes);
  endfunction

  /// XML Element
  /// Generate an XML element ( <tag attributes>data</tag> )
  function string xle_n(string tag, string data, string attributes="");
    xle_n = "";
    if (data != "") begin
      xle_n = {"<", tag, attributes, ">", data, "</", tag, ">\n"};
    end
  endfunction

  /// Generate the XML encapsulated report message, for logging
  virtual function string compose_xml_message(
    uvm_severity severity,
    int verbosity,
    string name,
    string id,
    string message,
    string filename,
    int    line
    );
    string my_message;
    uvm_severity_type sv;
    sv = uvm_severity_type'(severity);

    $swrite(my_message,"%s %s(%0d) @ %0d: %s[%s] %s\n",sv.name(),filename,line,$time,name,id,message);
    if (sv != UVM_INFO) begin
       // Keep track of this error message so we can report it
       all_error_details = {all_error_details,my_message};
       all_error_messages = {all_error_messages,my_message};
    end
    $swrite(compose_xml_message,"<![CDATA[%s]]>\n",my_message);
  endfunction

  // Returns the current time as seconds since 1970-01-01 00:00:00 UTC
  // Implemented as a system call to "date +%s" and the return value is parsed
  function integer now_in_seconds();
    integer FP;
    integer fgetsResult;
    integer sscanfResult;
    reg [8*10:1] str;
    
    // call "date" and put out time in seconds since Jan 1, 1970 (when time began, no doubt)
    // and put the results in a file called "now_in_seconds"
    $system("date +%s > now_in_seconds");                                                   
    
    // open the file for reading
    FP = $fopen("now_in_seconds","r");
    
    // get a string from the open file - "fgetsResult" should be a 1 - you can test 
    // that for completeness if you'd like
    fgetsResult = $fgets(str,FP);
    
    // convert the string to an integer - "sscanfResult" should also be a 1, and
    // you can test that, too, 
    sscanfResult = $sscanf(str,"%d",now_in_seconds);
    
    // close the file...
    $fclose(FP);  // closes the file

    // remove the file...
    $system("rm now_in_seconds");                                                   
  endfunction
endclass
`endif //_XML_REPORT_SERVER_SVH__
