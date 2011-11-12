# -*- coding: utf-8 -*-
require 'aws-sdk'
class RankingSimpledb
 attr :domain
  #
  # change integer score to string score
  # スコアの文字列化(文字列比較の場合に整数順になるようゼロパディング)
  #
  def self.score_str(score)
    if score.is_a? Integer
      sprintf("%012d",score)
    else
      score
    end
  end

  #
  # score + user_id  for sort
  # スコア+ユーザIDの文字列化(同じスコアの場合はユーザIDが大きい順に並べるため)
  #
  def self.to_id_score(score,u_id)
    sprintf("%s%012d",score_str(score),u_id)
  end

  #
  # formatize  for items
  # itemsにセットするレコード形式を作成
  #
  def self.to_rec(u_id,score)
    str_score = score_str(score)
    {"score" => score_str(score),"id_score" => to_id_score(score,u_id)}
  end

  #
  # create domain
  # domain(tableみたいなもの)を作成
  #
  def initialize(access_key,secret_access_key,ranking_name,simple_db_endpoint = "sdb.ap-northeast-1.amazonaws.com")
    AWS.config({ :access_key_id => access_key, :secret_access_key => secret_access_key,
               :simple_db_endpoint => simple_db_endpoint })
    db = AWS::SimpleDB.new()
    @domain = db.domains.create(ranking_name)
  end

  #
  # update ranking data. if u_id does not exist, create new data. if u_id exists in ranking, override new score
  # 同じ主キーがあった場合は、自動的に書き換えられる
  #
  def upsert(u_id,score)
    @domain.items.create(u_id.to_s,self.class.to_rec(u_id,score))
  end

  #
  # delete ranking data specified by u_id
  # 指定したレコードの削除
  #
  def delete(u_id)
    @domain.items[u_id.to_s].delete
  end

  # rank of u_id
  # 指定したユーザIDの順位
  #
  def rank_of_u_id(u_id)
    score = score_of_u_id(u_id)
    rank_by_score(score)
  end

  # score of u_id
  # 指定したユーザIDのスコア
  #
  def score_of_u_id(u_id)
    @domain.items[u_id.to_s].attributes["score"].values[0]
  end

  #
  # rank by score
  # 指定したスコアの順位
  #
  def rank_by_score(score)
    return @domain.items.count + 1 unless score
    @domain.items.where("score > \"#{self.class.score_str(score)}\"").count + 1
  end

  #
  # number of user in the score. same score user.
  # 指定したスコアにいる人数(同位タイ)
  #
  def user_num_of_score(score)
    @domain.items.where(:score => self.class.score_str(score)).count
  end

  #
  # return ranking top recored
  # 一番高いスコアのランキング情報
  #
  def top
    to_list(@domain.items.where("id_score is not null").order(:id_score,:desc).limit(1))[0]
  end

  #
  # top (list_num) list.
  # スコアが高い順にlist_num数分表示
  #
  def top_list(list_num)
    to_list(@domain.items.where("id_score is not null").order(:id_score,:desc).limit(list_num))
  end

  #
  # return list_num record above id_score. if inc is true, include specified id_score_record. 
  # use for paginate.
  # list_num数分、指定したスコア+ユーザIDよりも上にいるランキングを取得。incがtrueの場合は、指定したid_scoreのレコードも含める
  #
  def prev_list(list_num,id_score,inc=false)
    if inc
      clause = "id_score >= \"#{id_score}\""
    else
      clause = "id_score > \"#{id_score}\""
    end
    items = @domain.items.where(clause).order(:id_score,:asc).limit(list_num).to_a
    if items.count < list_num
      return top_list(list_num)
    end
    to_list(items.reverse)
  end

  #
  # return list_num record above id_score. if inc is true, include specified id_score_record. 
  # use for paginate.
  # list_num数分、指定したスコア+ユーザIDよりも下にいるランキングを取得。incがtrueの場合は、指定したid_scoreのレコードも含める
  #
  def next_list(list_num,id_score,inc=false)
    if inc
      clause = "id_score <= \"#{id_score}\""
    else
      clause = "id_score < \"#{id_score}\""
    end
    to_list(@domain.items.where(clause).order(:id_score,:desc).limit(list_num))
  end

  #
  # return list_num recored near u_id's score. include u_id score.
  # list_num数分、指定したユーザとそれ以下のユーザのランキングを取得。
  #
  def my_list(list_num,u_id)
    score = score_of_u_id(u_id)
    next_list(list_num,self.class.to_id_score(score,u_id),true)
  end

  #
  # change format of item_record [{"u_id"=>user id,"rank"=>rank,score"=>score,"id_score"=>score+u_id(zero padding)}, ...]
  # SimpleDBに登録したレコードを{"u_id"=>ユーザID,"rank"=>順位,"score"=>スコア,"id_score"=>スコア+ユーザID}
  # のフォーマットの配列に変換。
  #
  def to_list(list)
    records = []
    list.each{|elm|
      attrs = {}
      elm.attributes.each_value{|k,v| attrs[k] = v}
      attrs["u_id"] = elm.name.to_i
      records.push(attrs)
    }
    return [] if records.count == 0
    prev_score = records[0]["score"].to_i
    rank = rank_by_score(prev_score)
    count = user_num_of_score(prev_score)
    first_flg = true
    records.each do|entry|
      score = entry["score"].to_i
      id_score = entry["id_score"]
      if score != prev_score
        rank = count + rank
        count = 1
        prev_score = score
        first_flg = false
      else
        unless first_flg
          count += 1
        end
      end
      entry["score"] = score
      entry["rank"] = rank
    end
    records
  end
end
