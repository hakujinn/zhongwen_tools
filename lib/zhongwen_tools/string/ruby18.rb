# encoding: utf-8

class String
  define_method(:chars) do
    self.scan(/./mu).to_a
  end

  def size
    self.chars.size
  end

  def reverse(str = nil)
    self.chars.reverse.join
  end

  def gsub_with_hash(pattern, hash)
    gsub(pattern) do |m|
      hash[m]
    end
  end
end

module ZhongwenTools
  module String
    # TODO: replace deprecated constant UNICODE_REGEX.
  end
  def to_utf8(encoding = nil, encodings = nil)
    # FIXME: should substitute out known bad actors like space
    encodings = ['utf-8', 'GB18030', 'BIG5', 'GBK', 'GB2312'] if encodings.nil?
    encodings = encoding + encodings unless encoding.nil?
    raise 'Unable to Convert' if encodings.size == 0

    begin
      text = Iconv.conv('utf-8', encodings[0], self)
    rescue
      text = self.to_utf8(nil, encodings[1..-1])
    end
    text
  end

  def convert_regex(regex)
    str = regex.to_s
    regex.to_s.scan(/u[0-9A-Z]{4}/).each{|cp| str = str.sub('\\' + cp,cp.from_codepoint)}
    /#{str}/
  end

  def has_zh?(str = nil)
    str ||= self

    regex = {
      :zh => self.convert_regex(UNICODE_REGEX[:zh]),
      :punc => self.convert_regex(UNICODE_REGEX[:punc])
    }
    # str.scan(/#{regex[:zh]}|#{regex[:punc]}|\s/).join == str
    !self.fullwidth?(str) && (!str[regex[:zh]].nil? || !str[regex[:punc]].nil?)
  end

  def zh?(str = nil)
    str ||= self

    regex = {
      :zh => self.convert_regex(UNICODE_REGEX[:zh]),
      :punc => self.convert_regex(UNICODE_REGEX[:punc])
    }

    !str.fullwidth? && (str.scan(/(#{regex[:zh]}+|#{regex[:punc]}+|\s+)/).join == str)
  end

  def has_zh_punctuation?(str = nil)
    str ||= self
    regex = {
      :zh => self.convert_regex(UNICODE_REGEX[:zh]),
      :punc => self.convert_regex(UNICODE_REGEX[:punc])
    }

    !str[regex[:punc]].nil?
  end

  def strip_zh_punctuation(str = nil)
    str ||= self

    str.gsub(self.convert_regex(UNICODE_REGEX[:punc]), '')
  end

  def to_halfwidth(str = nil)
    str ||= self
    matches = str.scan(/([０-９Ａ-Ｚａ-ｚ％．：＃＄＆＋－／＼＝；＜＞])/u).uniq.flatten

    matches.each do |match|
      replacement = FW_HW[match]
      str = str.gsub(match, replacement)
    end

    str
  end
end
