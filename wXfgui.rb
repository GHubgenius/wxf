#!/usr/bin/env jruby

case RUBY_PLATFORM
when 'java'
else
   print("\e[1;31m[wXf error]\e[0m Please start this application using JRuby\n")
   exit
end

wXfbase = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__
WXFDIR = File.join(File.expand_path(File.dirname(wXfbase)))
$:.unshift(File.join(File.expand_path(File.dirname(wXfbase)), 'jlib'))


#System level requirements
  require 'java'
  require 'rubygems'
  
# Gem requirements
begin
  require 'jdbc/sqlite3'
  require 'buby'
rescue LoadError => le
  print("\e[1;31m[wXf error]\e[0m Please ensure you have the following gems installed:\n")
  print("1) buby\n")
  print("2) jdbc-sqlite3\n")
  exit
end


#wXf gui elements
require 'wXfgui/workspace_chooser'
require 'wXfgui/workspace_creator'
require 'wXfgui/request_response_tabbed_pane'
require 'wXfgui/wxfgui_menu'
require 'wXfgui/modules_tree'
require 'wXfgui/mod_loader'
require 'wXfgui/popup_click_listener'
require 'wXfgui/request_response_tabbed_pane'
require 'wXfgui/main_tabs'
require 'wXfgui/checkbox_rendering'
require 'wXfgui/decision_tree'
require 'wXfgui/scope_panel'
require 'wXfgui/log_panel'

# Time to require native wXf stuff
require 'wXf/wXfassists'
require 'wXf/wXfconductors'
require 'wXf/wXfconstants'
require 'wXf/wXflog'
require 'wXf/wXfmod_factory'
require 'wXf/wXfui'
require 'wXf/wXfwebserver'


# Necessary libs, well, most of them......
import java.util.LinkedList
import java.util.Properties
import javax.swing.JTree
import javax.swing.tree.DefaultMutableTreeNode
import javax.swing.tree.TreeModel
import java.awt.Dimension
import java.awt.Color
import java.awt.Font
import javax.swing.BorderFactory
import javax.swing.SwingConstants
import javax.swing.JFrame
import javax.swing.JLabel
import javax.swing.JTextArea
import javax.swing.JComponent
import javax.swing.JList
import javax.swing.JPanel
import javax.swing.JMenuBar
import javax.swing.JScrollPane
import javax.swing.JTabbedPane
import javax.swing.GroupLayout
import java.awt.event.MouseListener
import java.awt.event.FocusListener
import java.awt.event.MouseEvent

module WxfGui
class WxfGuiTabbedPane < JTabbedPane
    
  def initialize
    super(JTabbedPane::TOP, JTabbedPane::SCROLL_TAB_LAYOUT)
    @wXf_cc_panel = WxfMainPanel.new   
    @wXf_analysis_panel = WxfAnalysisPanel.new
    @wXf_buby_panel = WxfBubyPanel.new  
    add("Main", @wXf_cc_panel)
    add("Analysis", @wXf_analysis_panel)
    add("Buby", @wXf_buby_panel)
    listener
  end
  
  def add(*vals)
    name, obj = vals
    self.add_tab(name, obj)
  end
  
  def listener(*params)
    self.add_change_listener do |event|
    #=begin
    #THIS IS ALL STUBBED CODE, USING IT AS AN EXAMPLE.
  
    end
    #=end 
  end
  
  def restore
    @wXf_cc_panel.restore
  end
  
  def send_log_text(*params)
    @wXf_cc_panel.send_log_text(*params)
  end
end


#
#
# This is going to be a buby tab where the buby work can happen on its own
#
#
class WxfBubyPanel < JPanel
  
   include MouseListener
   include FocusListener
  
  def initialize
    super
  end
  
end

#
#
# This is going to be an analysis tab where the decision tree works its magic
#
#
class WxfAnalysisPanel < JPanel
  
   include MouseListener
   include FocusListener
  
  def initialize
    super
  end
  
end

class WxfMainPanel < JPanel
  
   include MouseListener
  
  def initialize
    super
    init
  end
  
  def init

=begin    
      #
      # Templated Request/Response Tabbed Panes
      #
      
      rrtp = RequestResponseTabbedPane.new

      scroll_list  = RequestResponseList.new
      scroll_checklist = JScrollPane.new(scroll_list)
=end

      @main_tabs = MainTabs.new
      
      
      #
      # SCROLL PANE
      #
      
      treeModel = ModulesTree.new(ModLoader.new)
    
      tree_1 = JTree.new(treeModel)
      tree_1.shows_root_handles = true
      tree_1.addMouseListener(ModulesPopUpClickListener.new(tree_1, self))
      t_scroll_pane_1 = JScrollPane.new(tree_1)
      t_scroll_pane_2 = DecisionPanel.new
  
      
      #
      # SPLIT PANES  
      #
      
           
      split_pane1 = JSplitPane.new JSplitPane::VERTICAL_SPLIT
      split_pane1.setDividerLocation 390
      split_pane1.add t_scroll_pane_2
      split_pane1.add @main_tabs
        
      
      split_pane2 = JSplitPane.new JSplitPane::HORIZONTAL_SPLIT
      split_pane2.setDividerLocation 300
      split_pane2.add t_scroll_pane_1
      split_pane2.add split_pane1
      
       
      
      #
      # GROUP LAYOUT OPTIONS
      #
      
      layout = GroupLayout.new self
      # Add Group Layout to the frame
      self.setLayout layout
      # Create sensible gaps in components (like buttons)
      layout.setAutoCreateGaps true
      layout.setAutoCreateContainerGaps true
    
      sh1 = layout.createSequentialGroup
      sv1 = layout.createSequentialGroup
      p1 = layout.createParallelGroup
      p2 = layout.createParallelGroup
      
      layout.setHorizontalGroup sh1
      layout.setVerticalGroup sv1
    
      sh1.addComponent split_pane2
      sh1.addGroup p1
       
      p2.addComponent split_pane2
      sv1.addGroup p2
      
  end
  
  def restore
    @main_tabs.restore
  end
  
  def send_log_text(*params)
    @main_tabs.send_log_text(*params)
  end
end

class Wxfgui < JFrame
  
  def initialize
      super "The Web Exploitation Framework"      
      self.initUI
      check_workspace
  end
    
  def initUI
      
      @wXf_gui_tabbed_pane = WxfGuiTabbedPane.new
      self.add @wXf_gui_tabbed_pane
      
      #
      # MENU BAR
      #
      
      menuBar = JMenuBar.new
      menuBar.add WxfMenu.new(self)
      menuBar.add BubyMenu.new
      menuBar.add AboutMenu.new
            
      #
      # FRAME OPTIONS
      #
      
      # Set the overall side of the frame
      self.setJMenuBar menuBar
      self.setPreferredSize Dimension.new 1300, 900
      self.pack
    
      self.setDefaultCloseOperation JFrame::EXIT_ON_CLOSE
      self.setLocationRelativeTo nil
      self.setVisible true
  end
  
  def restore
    @wXf_gui_tabbed_pane.restore
  end
  
  def send_log_text(*params)
    @wXf_gui_tabbed_pane.send_log_text(*params)
  end
  
  def check_workspace
      home_dir = ENV['HOME']
      wXf_home_dir = "#{home_dir}/.wXf"
      pwd = Dir.pwd
      db_exists = false
  
      Dir.foreach(wXf_home_dir) do |f|
        if File.extname(f) == ".db"
            db_exists = true
          next
        end
      end
  
      if db_exists == true
        WorkspaceChooser.new(self)
      else
        WorkspaceCreator.new(self)     
      end   
  end
  
  
end


end

WxfGui::Wxfgui.new
