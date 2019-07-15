# frozen_string_literal: true

require 'filter_expression_tree.rb'

describe FilterExpressionTree do

  # PROJECT="the hobbit" AND SHOT=1 OR SHOT=40
  # PROJECT="the hobbit" AND (SHOT=1 OR SHOT=40)
  
  it 'should create an OR expression' do
    expression = 'PROJECT="the hobbit" OR PROJECT="lotr'
    tree = FilterExpressionTree.build(expression)
    expect(tree).to be_an(OrExpression)
    expect(tree.left).to be_an(LeafExpression)
    expect(tree.right).to be_an(LeafExpression)
  end

  it 'should create an AND expression' do
    expression = 'PROJECT="the hobbit" AND PROJECT="lotr'
    tree = FilterExpressionTree.build(expression)
    expect(tree).to be_an(AndExpression)
    expect(tree.left).to be_an(LeafExpression)
    expect(tree.right).to be_an(LeafExpression)
  end

  it 'should create OR expression if both AND and OR are present' do
    expression = 'PROJECT="the hobbit" AND PROJECT="the hobbit 2" OR PROJECT="lotr'
    tree = FilterExpressionTree.build(expression)
    expect(tree).to be_an(OrExpression)
    expect(tree.left).to be_an(AndExpression)
    expect(tree.left.left).to be_an(LeafExpression)
    expect(tree.left.right).to be_an(LeafExpression)
    expect(tree.right).to be_an(LeafExpression)
  end

  it 'should evaluate parenthesis single parenthesis first' do
    expression = 'PROJECT="the hobbit" AND (PROJECT="the hobbit 2" OR PROJECT="lotr)'
    tree = FilterExpressionTree.build(expression)
    expect(tree).to be_an(AndExpression)
    expect(tree.right).to be_an(OrExpression)
    expect(tree.right.left).to be_an(LeafExpression)
    expect(tree.right.right).to be_an(LeafExpression)
    expect(tree.left).to be_an(LeafExpression)
  end

   it 'should build tree evaluating multiple parenthesis first' do
    expression = '(SHOT="1" OR SHOT="40) AND (PROJECT="the hobbit 2" OR PROJECT="lotr)'
    tree = FilterExpressionTree.build(expression)
    expect(tree).to be_an(AndExpression)
    expect(tree.left).to be_an(OrExpression)
    expect(tree.left.left).to be_an(LeafExpression)
    expect(tree.left.right).to be_an(LeafExpression)
    expect(tree.right).to be_an(OrExpression)
    expect(tree.right.left).to be_an(LeafExpression)
    expect(tree.right.right).to be_an(LeafExpression)
  end

  it 'should build tree considering AND higher priority' do
    expression = 'SHOT="1" OR SHOT="40 AND PROJECT="the hobbit 2"'
    tree = FilterExpressionTree.build(expression)
    expect(tree).to be_an(OrExpression)
    expect(tree.left).to be_an(LeafExpression)
    expect(tree.right).to be_an(AndExpression)
    expect(tree.right.left).to be_an(LeafExpression)
    expect(tree.right.right).to be_an(LeafExpression)
  end

  # it 'should build tree with multiple OR expressions' do
  #   expression = 'SHOT="1" OR SHOT="40" AND PROJECT="the hobbit 2" OR SHOT="42" AND PROJECT="lotr"'
  #   tree = FilterExpressionTree.build(expression)
  #   expect(tree).to be_an(OrExpression)
  #   expect(tree.left).to be_an(LeafExpression)
  #   expect(tree.right).to be_an(AndExpression)
  #   expect(tree.right.left).to be_an(LeafExpression)
  #   expect(tree.right.right).to be_an(LeafExpression)
  # end

  it 'should evaluate parenthesis first' do
    expression = '(SHOT="1" AND SHOT="40) OR (PROJECT="the hobbit 2" AND PROJECT="lotr)'
    tree = FilterExpressionTree.build(expression)
    expect(tree).to be_an(OrExpression)
    expect(tree.left).to be_an(AndExpression)
    expect(tree.left.left).to be_an(LeafExpression)
    expect(tree.left.right).to be_an(LeafExpression)
    expect(tree.right).to be_an(AndExpression)
    expect(tree.right.left).to be_an(LeafExpression)
    expect(tree.right.right).to be_an(LeafExpression)
  end

   it 'should evaluate parenthesis first' do
    expression = 'SHOT="1" AND SHOT="40 OR PROJECT="the hobbit 2" AND PROJECT="lotr'
    tree = FilterExpressionTree.build(expression)
    expect(tree).to be_an(OrExpression)
    expect(tree.left).to be_an(AndExpression)
    expect(tree.left.left).to be_an(LeafExpression)
    expect(tree.left.right).to be_an(LeafExpression)
    expect(tree.right).to be_an(AndExpression)
    expect(tree.right.left).to be_an(LeafExpression)
    expect(tree.right.right).to be_an(LeafExpression)
  end


end