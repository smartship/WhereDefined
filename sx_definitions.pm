use strict;
use warnings;
use File::Find;  
use File::Copy;
use Cwd;
use File::Basename;

# for lexical part

use constant $SX_COMMENT_SECTION_START  => "#|";
use constant $SX_COMMENT_SECTION_END    => "|#";
use constant $SX_COMMENT_INLINE         => ";";
use constant $SX_QUOTE                  => "\"";
use constant $SX_LEFT_BRAKET            => "(";
use constant $SX_RIGHT_BRAKET           => ")";
use constant $SX_QUOTE_MARK				=> "\\\""
use constant $SX_DELIMITION_SYMBOL_NORMAL      => "#|;\"()[]{}";
use constant $SX_DELIMITION_SYMBOL_COMMENT	   => "|"
use constant $SX_DELIMITION_SYMBOL_QUOTE	   => "\""

use constant %SX_LEXICAL_DELIMITIONS => 
(
	delimit_symbol			=>	$SX_DELIMITION_SYMBOL,
	# delimitions should be arranged from max to min
	delimitions 			=> 	@(@($SX_COMMENT_SECTION_START,
					 		 		$SX_COMMENT_SECTION_END,
					 		 		SX_QUOTE_MARK),
								  @($SX_COMMENT_INLINE,
									$SX_QUOTE,
									$SX_LEFT_BRAKET,
									$SX_RIGHT_BRAKET),
								 ),
	inline_comment			=>	$SX_COMMENT_INLINE,
	section_comment_start	=>	$SX_COMMENT_SECTION_START,
	section_comment_end		=>	$SX_COMMENT_SECTION_END,
	quote 					=>  $SX_QUOTE
);

"sx_definitions.pm"