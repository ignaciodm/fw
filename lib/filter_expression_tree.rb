# frozen_string_literal: true

# add comment

class LeafExpression
  
  attr_accessor :key, :value
  def initialize(expression)
    @key, @value = expression.downcase.split('=')
  end

  def evaluate(record)
    record.send(key) == value
  end
end

class LogicalExpression
  attr_accessor :left, :right
  
  def initialize(left, right, reduced: nil)
    puts "LEFT: #{left}"
    puts "RIGHT: #{right}"
    @left =   build_expression(left, reduced)
    @right =  build_expression(right, reduced)
  end

  def build_expression(expression, reduced = nil)
    if reduced
      if expression.include?("$")
        reduced
      else
        FilterExpressionTree.build(expression)
      end
    else
      FilterExpressionTree.build(expression)
    end
  end
end

class AndExpression < LogicalExpression
  
  def evaluate
    @left.evaluate && @right.evaluate 
  end
end

class OrExpression < LogicalExpression

  def evaluate
    @left.evaluate || @right.evaluate
  end
end

class FilterExpressionTree
  PARENTHESIS_REGEX = /\(.*?\)/

  def self.build_logical_expression_tree(expression, reduced: nil)
    is_and = is_and_expression(expression)
    is_or = is_or_expression(expression)
    if is_and && is_or
      # and higher priority, so create or expression to keep and expressions to be evaluated first
      exp = OrExpression.new(*expression.split(' OR '), reduced: reduced)
    else
      if is_and_expression(expression)
          exp = AndExpression.new(*expression.split(' AND '), reduced: reduced)
      else
        if is_or_expression(expression)
          exp = OrExpression.new(*expression.split(' OR '), reduced: reduced)
        else
          exp = LeafExpression.new(expression)
        end
      end
    end
  end

  def self.remove_parenthesis(str)
    str.gsub("(", "").gsub(")", "")
  end

  def self.build(expression)
    if match_data = expression.match(PARENTHESIS_REGEX)
      without_parenthesis_str = remove_parenthesis(match_data.to_s)
      parenthesis_expression = build_logical_expression_tree(without_parenthesis_str)
      reduced_expression = expression.gsub(PARENTHESIS_REGEX, "$1")

      puts "reduced_expression"
      puts reduced_expression
      exp = build_logical_expression_tree(reduced_expression, reduced: parenthesis_expression )
    else
      exp = build_logical_expression_tree(expression)
    end

    exp
    
  end
    
  def self.split_by_parenthesis(str)
    str.split(/[()]+/)
  end

  def self.is_or_expression(expression)
    expression.include?(' OR ')
  end

  def self.is_and_expression(expression)
    expression.include?(' AND ')
  end

end
