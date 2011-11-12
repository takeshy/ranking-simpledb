# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RankingSimpledb do
  before(:all) do
    @ranking_name = "num_of_win"
    @rank = RankingSimpledb.new(ENV["AWS_ACCESS_KEY"],ENV["AWS_SECRET_ACCESS_KEY"],@ranking_name,"sdb.ap-northeast-1.amazonaws.com")
    @list_num = 10
    @num_win = 1
    @num_win2 = 2
    @num_win3 = 3
    @num_win4 = 4
    @num_win5 = 5
    @num_win6 = 6
    @num_win7 = 7
    @num_win8 = 8
    @num_win9 = 9
    @num_win10 = 10
    @num_win11 = 11
    @u_id = 1001
    @u_id2 = 1002
    @u_id3 = 1003
    @u_id4 = 1004
    @u_id5 = 1005
    @u_id6 = 1006
    @u_id7 = 1007
    @u_id8 = 1008
    @u_id9 = 1009
    @u_id10 = 1010
    @u_id11 = 1011
    @rank.upsert(@u_id,@num_win)
    @rank.upsert(@u_id2,@num_win2)
    @rank.upsert(@u_id3,@num_win2)
    @rank.upsert(@u_id4,@num_win4)
    @rank.upsert(@u_id5,@num_win5)
    @rank.upsert(@u_id6,@num_win6)
    @rank.upsert(@u_id7,@num_win7)
    @rank.upsert(@u_id8,@num_win8)
    @rank.upsert(@u_id9,@num_win9)
    @rank.upsert(@u_id10,@num_win10)
    @rank.upsert(@u_id11,@num_win11)
    @rank.upsert(@u_id4,@num_win11)
    @rank.upsert(@u_id5,@num_win11)
    @rank.upsert(@u_id6,@num_win11)
    @rank.upsert(@u_id7,@num_win11)
    @rank.upsert(@u_id8,@num_win11)
    @rank.upsert(@u_id9,@num_win11)
    @rank.upsert(@u_id10,@num_win11)
  end
  describe "initialize" do
    context "順位が取れること" do
      it { @rank.rank_by_score(@num_win).should == 11}
      it { @rank.rank_by_score(@num_win2).should == 9}
    end
  end
 describe "順位リスト" do
    context "Top10" do
      it { @rank.top_list(@list_num).should == [
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id11),"u_id" => @u_id11,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id10),"u_id" => @u_id10,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id9), "u_id" => @u_id9,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id8), "u_id" => @u_id8,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id7), "u_id" => @u_id7,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id6), "u_id" => @u_id6,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id5), "u_id" => @u_id5,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id4), "u_id" => @u_id4,"rank" => 1},
 {"score"=>2, "id_score" => RankingSimpledb.to_id_score(2,@u_id3),  "u_id" => @u_id3,"rank" => 9},
 {"score"=>2, "id_score" => RankingSimpledb.to_id_score(2,@u_id2),  "u_id" => @u_id2,"rank" => 9},
                                        ]
        }
    end
  end
  describe "ページング" do
    context "next_list" do
      it{@rank.next_list(@list_num,RankingSimpledb.to_id_score(2,@u_id2)).should == [
         {"score"=>1, "id_score" => RankingSimpledb.to_id_score(1,@u_id),"u_id" => @u_id,"rank" => 11}
      ]}
    end
    context "prev_list" do
      it{@rank.prev_list(@list_num,RankingSimpledb.to_id_score(1,@u_id)).should == [
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id11),"u_id" => @u_id11,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id10),"u_id" => @u_id10,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id9), "u_id" => @u_id9,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id8), "u_id" => @u_id8,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id7), "u_id" => @u_id7,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id6), "u_id" => @u_id6,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id5), "u_id" => @u_id5,"rank" => 1},
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id4), "u_id" => @u_id4,"rank" => 1},
 {"score"=>2, "id_score" => RankingSimpledb.to_id_score(2,@u_id3),  "u_id" => @u_id3,"rank" => 9},
 {"score"=>2, "id_score" => RankingSimpledb.to_id_score(2,@u_id2),  "u_id" => @u_id2,"rank" => 9},
      ]}
    end
    context "my_list" do
      context "上位に3名以上下位に2名以上" do
        it{@rank.my_list(3,@u_id4).should == [
 {"score"=>11,"id_score" => RankingSimpledb.to_id_score(11,@u_id4),"u_id" => @u_id4,"rank" => 1},
 {"score"=>2,"id_score" => RankingSimpledb.to_id_score(2,@u_id3),"u_id" => @u_id3,"rank" => 9},
 {"score"=>2,"id_score" => RankingSimpledb.to_id_score(2,@u_id2), "u_id" => @u_id2,"rank" => 9},
        ]}
      end
      context "下位がいない" do
        it{@rank.my_list(3,@u_id).should == [
 {"score"=>1,"id_score" => RankingSimpledb.to_id_score(1,@u_id),"u_id" => @u_id,"rank" => 11},
        ]}
      end
    end
  end
  describe "更新" do
    before do
      @num_win12 = 12
      @rank.upsert(@u_id3,@num_win12)
    end
    context "単独1位になる" do
      it {@rank.rank_by_score(@num_win12).should == 1}
      it {@rank.rank_of_u_id(@u_id3).should == 1}
      it {@rank.top().should == {"score"=>12, "id_score" => RankingSimpledb.to_id_score(12,@u_id3),  "u_id" => @u_id3,"rank" => 1}}
    end
  end
  after(:all) do
    @ranking_name = "num_of_win"
    @rank = RankingSimpledb.new(ENV["AWS_ACCESS_KEY"],ENV["AWS_SECRET_ACCESS_KEY"],@ranking_name,"sdb.ap-northeast-1.amazonaws.com")
    @rank.domain.delete!
  end
end
