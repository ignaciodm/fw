Considerations

1) The solution is over engineered. I new I had one week and I spent around 25-30 hours on it. 
2) It has been around 9 months without touching Ruby, and I preferred to start doing than "re-studying" 
the language. There are lots of things that could be done in a better way
3) I did all 4 tasks:
 task 1 - 
 a) Reading file in the original format. 
 b) I am not storing it in a new format file. Once it is loaded, its kept in memory for further query consultations
 c) I tried to immitate the relational databases model, and create a separate table for keeping the index
 d) At this points I started over-engineering the solution, trying to create a small framework like rails to support 
 the tables, different columns, attribute validations, etc

 task 2 - 3
   I kept a database/query.rb file and a project_query_command_line.rb which adapts the command line string to a more
   object oriented query. These two classes could have similar behaviour, and I should revisit and think if there is duplicated logic there.

 task 4
   I created a tree to keep the logical expressions. This part was very interesting.
   I am not the best with regular expression so this needs better experience in that area
   to expand a support more complex queries

4) Testing 
  a) I relied on rspec to help developing this "mini custom rails & query tool". All the tests are passing (51), except one 
  which demonstrates the feature that the logical expression tree does not handle correctly for now

  to run the tests, just do: 'bin/test' on the root of the folder

  b) Last tests added have wrong descriptions :)

5) I relied on rubocop to keep the style of the code. 
  There are things I forgot about the ruby standards and this was a lot of help

6) There is only one model today which is Project. 
   This solution could support the creation of any other entity without much effort
   New tables could be added in a similar way we do in rails like

   data_store.create_table Project do |t|
      t.string :project # max 64
      t.string :shot # max 64
      t.integer :version # 0 and 65535
      t.string :status # max 32
      t.date :finish_date # YYYY-MM-DD
      t.float :internal_bid
      t.timestamp :created_date # YYYY-MM-DD HH:MM format
   end


7) Validations: The "mini-framework" support only one validation for string length for now.
  Different column classes could have more validations. Check Column::String and Project to see how it is implemented.
  Even the project is described as 64 characters max, I used length: { max: 15} in the Project, just for testing and I forgot to change it

8) I would have like to use more metaprogramming concepts to create this mini-framework but I am a bit rusty at this moment with Ruby and prefer to spent my time doing than refreshing

9) Type ruby query.rb in the console to see how to use the program

10) argv handling should be improved. For example, there is no validation that aggregated funtions should be use with the group_by clause. It is just a time restriction. The code is already doing some checks

11) There are many things I would do, like nesting stuff that makes sense in Modules, renaming long_variable_names to shorter ones and more descriptive, etc, but there is never enough time

12) Hope you like the solution. I am really happy with it. Besides we work together or not, it was a lot of fun and put me under pressure

13) There are some warnings I need to address




