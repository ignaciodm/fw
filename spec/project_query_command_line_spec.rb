# frozen_string_literal: true

require 'project_query_command_line.rb'

describe ProjectQueryCommandLine do
  it 'should accept -s option' do
    argv_as_string = ' -s PROJECT,SHOT,VERSION'
    expect(ProjectQueryCommandLine.run(argv_as_string)).to eq([
                                                                'the hobbit,01,64',
                                                                'lotr,03,16',
                                                                'the hobbit,40,32',
                                                                'king kong,42,128'
                                                              ])
  end

  it 'should accept -s option and -o together' do
    argv_as_string = ' -s PROJECT,SHOT,VERSION,STATUS -o FINISH_DATE,INTERNAL_BID'
    expect(ProjectQueryCommandLine.run(argv_as_string)).to eq([
                                                                'lotr,03,16,finished',
                                                                'king kong,42,128,not required',
                                                                'the hobbit,40,32,finished',
                                                                'the hobbit,01,64,scheduled'
                                                              ])
  end

  it 'should accept -s option and -f together' do
    argv_as_string = ' -s PROJECT,SHOT,VERSION,STATUS -f FINISH_DATE=2006-07-22'
    expect(ProjectQueryCommandLine.run(argv_as_string)).to eq(['king kong,42,128,not required'])
  end

  it 'should accept sum and collect option and -g together' do
    argv_as_string = ' -s PROJECT,INTERNAL_BID:sum,SHOT:collect -g PROJECT'
    expect(ProjectQueryCommandLine.run(argv_as_string)).to eq([
                                                                'the hobbit,67.8,[01,40]',
                                                                'lotr,15.0,[03]',
                                                                'king kong,30.0,[42]'
                                                              ])
  end

  it 'should accept sum and collect option and -g together' do
    expected = ['the hobbit,67.8,[01,40]', 'lotr,15.0,[03]', 'king kong,30.0,[42]']
    argv_as_string = ' -s PROJECT,INTERNAL_BID:sum,SHOT:collect -g PROJECT'
    expect(ProjectQueryCommandLine.run(argv_as_string)).to eq(expected)
  end

  it 'should accept min and max and -g together' do
    argv_as_string = ' -s PROJECT,INTERNAL_BID:min,SHOT:max -g PROJECT'
    expect(ProjectQueryCommandLine.run(argv_as_string)).to eq([
                                                                'the hobbit,22.8,40',
                                                                'lotr,15.0,03',
                                                                'king kong,30.0,42'
                                                              ])
  end

  it 'should accept count and -g together' do
    argv_as_string = ' -s PROJECT,SHOT:count -g PROJECT'
    expect(ProjectQueryCommandLine.run(argv_as_string)).to eq([
                                                                'the hobbit,2',
                                                                'lotr,1',
                                                                'king kong,1'
                                                              ])
  end

  it 'should order by finish date' do
    argv_as_string = ' -o FINISH_DATE'
    expect(ProjectQueryCommandLine.run(argv_as_string)).to eq([
                                                                'lotr,03,16,finished,2001-05-15,15.0,2001-04-01 06:47',
                                                                'king kong,42,128,not required,2006-07-22,30.0,2006-10-15 09:14',
                                                                'the hobbit,01,64,scheduled,2010-05-15,45.0,2010-04-01 13:35',
                                                                'the hobbit,40,32,finished,2010-05-15,22.8,2010-03-22 01:10'
                                                              ])
  end

  it 'should order by created date' do
    expect(ProjectQueryCommandLine.run(' -o CREATED_DATE')).to eq([
                                                                   'lotr,03,16,finished,2001-05-15,15.0,2001-04-01 06:47',
                                                                   'king kong,42,128,not required,2006-07-22,30.0,2006-10-15 09:14',
                                                                   'the hobbit,40,32,finished,2010-05-15,22.8,2010-03-22 01:10',
                                                                   'the hobbit,01,64,scheduled,2010-05-15,45.0,2010-04-01 13:35'
                                                                 ])
  end

  # PROJECT="the hobbit" AND SHOT=1 OR SHOT=40
  # PROJECT="the hobbit" AND (SHOT=1 OR SHOT=40)

  
  it 'should filter by multiple projects' do
    argv_as_string = ' -s PROJECT,INTERNAL_BID -f PROJECT="the hobbit" OR PROJECT="lotr"'
    expect(ProjectQueryCommandLine.run(argv_as_string)).to eq([
                                                          'lotr,03,16,finished,2001-05-15,15.0,2001-04-01 06:47',
                                                          'king kong,42,128,not required,2006-07-22,30.0,2006-10-15 09:14',
                                                          'the hobbit,40,32,finished,2010-05-15,22.8,2010-03-22 01:10',
                                                          'the hobbit,01,64,scheduled,2010-05-15,45.0,2010-04-01 13:35'
                                                        ])
  end

end