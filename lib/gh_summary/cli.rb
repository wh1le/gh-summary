module GhSummary
  class CLI
    include Colors

    INDENT_SECTION = 2
    INDENT_ITEM    = 4
    INDENT_SUB     = 6

    def initialize
    end

    def divider
      output "#{DIM}#{"─" * 60}#{RESET}"
    end

    def header(color, text)
      divider
      output "#{BOLD}#{color}#{left_padding(text, INDENT_SECTION)}#{RESET}"
    end

    def item(repository, title, url)
      output left_padding("#{repository} — #{title}", INDENT_ITEM)
      output left_padding(url, INDENT_SUB)
    end

    def sub_item(text)
      output left_padding(text, INDENT_SUB)
    end

    def group(label)
      output left_padding(label, INDENT_ITEM)
    end

    def count(number, label)
      output "#{DIM}#{left_padding("(#{number} #{label})", INDENT_SECTION)}#{RESET}"
    end

    def empty(text)
      output "#{DIM}#{left_padding(text, INDENT_SECTION)}#{RESET}"
    end

    def success(text)
      output "#{GREEN}#{left_padding(text, INDENT_SECTION)}#{RESET}"
    end

    def error(text)
      $stderr.puts "#{RED}#{left_padding(text, INDENT_SECTION)}#{RESET}"
    end

    def banner
      output "\n#{BOLD}#{CYAN}#{left_padding("GitHub Summary", INDENT_SECTION)}#{RESET}  #{DIM}#{Time.now.strftime("%Y-%m-%d %H:%M")}#{RESET}"
    end

    def table(columns, rows)
      column_widths = columns.map(&:length)
      rows.each do |row|
        row.each_with_index { |cell, index| column_widths[index] = [column_widths[index] || 0, cell.length].max }
      end

      format_string = column_widths.map { |width| "%-#{width}s" }.join("  ")
      output "#{DIM}#{left_padding(sprintf(format_string, *columns), INDENT_SECTION)}#{RESET}"
      rows.each { |row| output left_padding(sprintf(format_string, *row), INDENT_SECTION) }
    end

    def newline
      output
    end

    private

    def output(text = "")
      puts text
    end

    def left_padding(text, spacing = INDENT_SECTION)
      "#{" " * spacing}#{text}"
    end
  end
end
