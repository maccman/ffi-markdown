require "ffi"
require "ffi-markdown/version"

module FFI
  def self.map_library_name(lib)
    lib = lib.to_s unless lib.kind_of?(String)
    lib = Library::LIBC if lib == 'c'

    if lib && File.basename(lib) == lib
      lib = Platform::LIBPREFIX + lib unless lib =~ /^#{Platform::LIBPREFIX}/
      lib = lib + Platform::LIBSUFFIX unless lib =~ /\..+$/
    end

    lib
  end
end

class Markdown
  module MKD
    extend FFI::Library
    ffi_lib "markdown.so"
    
    attach_function :mkd_string, [:string, :int, :int], :pointer
    attach_function :mkd_compile, [:pointer, :int], :int
    attach_function :mkd_document, [:pointer, :pointer], :int
    attach_function :mkd_css, [:pointer, :pointer], :int
    attach_function :mkd_toc, [:pointer, :pointer], :int
    attach_function :mkd_doc_title, [:pointer], :char
    attach_function :mkd_doc_author, [:pointer], :char
    attach_function :mkd_doc_date, [:pointer], :char
    attach_function :mkd_with_html5_tags, [], :void
    attach_function :mkd_cleanup, [:pointer], :void
    
    MKD_NOLINKS	        = 0x00000001
    MKD_NOIMAGE	        = 0x00000002
    MKD_NOPANTS	        = 0x00000004
    MKD_NOHTML	        = 0x00000008
    MKD_STRICT	        = 0x00000010
    MKD_TAGTEXT	        = 0x00000020
    MKD_NO_EXT	        = 0x00000040
    MKD_CDATA	          = 0x00000080
    MKD_NOSUPERSCRIPT   = 0x00000100
    MKD_NORELAXED	      = 0x00000200
    MKD_NOTABLES	      = 0x00000400
    MKD_NOSTRIKETHROUGH = 0x00000800
    MKD_TOC		          = 0x00001000
    MKD_1_COMPAT	      = 0x00002000
    MKD_AUTOLINK	      = 0x00004000
    MKD_SAFELINK	      = 0x00008000
    MKD_NOHEADER	      = 0x00010000
    MKD_TABSTOP	        = 0x00020000
    MKD_NODIVQUOTE	    = 0x00040000
    MKD_NOALPHALIST	    = 0x00080000
    MKD_NODLIST	        = 0x00100000
    MKD_EXTRA_FOOTNOTE  = 0x00200000
    IS_LABEL	          = 0x08000000
    USER_FLAGS	        = 0x0FFFFFFF
    INPUT_MASK	        = MKD_NOHEADER|MKD_TABSTOP    
  end
  
  attr_reader :markdown, :flags
  
  def initialize(markdown, options = {})
    @markdown = markdown
    @flags    = generate_flags(options)
    
    MKD.mkd_with_html5_tags()
    @mkd = MKD.mkd_string(@markdown, @markdown.size, @flags)
    @mkd = FFI::AutoPointer.new(@mkd, MKD.method(:mkd_cleanup))
    MKD.mkd_compile(@mkd, @flags)
  end
  
  def html
    ptr = FFI::MemoryPointer.new :pointer
  	MKD.mkd_document(@mkd, ptr)
    ptr = ptr.read_pointer
    ptr.null? ? nil : ptr.read_string
  end
  
  def css
    ptr = FFI::MemoryPointer.new :pointer
  	MKD.mkd_css(@mkd, ptr)
    ptr = ptr.read_pointer
    ptr.null? ? nil : ptr.read_string
  end
  
  def toc
    ptr = FFI::MemoryPointer.new :pointer
  	MKD.mkd_toc(@mkd, ptr)
    ptr = ptr.read_pointer
    ptr.null? ? nil : ptr.read_string
  end
  
  protected
  
    def generate_flags(options = {})
      flags = MKD::MKD_TABSTOP
      flags |= MKD::MKD_NOLINKS if options[:links] == false
      flags |= MKD::MKD_NOIMAGE if options[:image] == false
      flags |= MKD::MKD_NOPANTS if options[:pants] == false
      flags |= MKD::MKD_NOHTML  if options[:html] == false
      flags |= MKD::MKD_STRICT  if options[:strict] == false
      flags |= MKD::MKD_TOC     if options[:toc] == true
      flags |= MKD::MKD_NOPANTS if options[:pants] == false
      flags |= options[:flags]  if options[:flags]
      flags
    end
end