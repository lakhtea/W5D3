require 'sqlite3'
require 'singleton'

class QuestionsDatabase < SQLite3::Database
  include Singleton
  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question

  attr_reader :associated_author_id, :id
  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @associated_author_id = options['associated_author_id']
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM questions
      WHERE id = ?
    SQL

    Question.new(question.first)
  end

  def self.find_by_author_id(author_id)
    author = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT * from questions
      WHERE associated_author_id = ?
    SQL

    Question.new(author.first)
  end

  def author
    Users.find_by_id(self.associated_author_id)
  end

  def replies
    Reply.find_by_question_id(self.id)
  end
end

class Users

    attr_reader :id, :fname, :lname

    def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT * FROM users
      WHERE fname = ? AND lname = ?
    SQL

    Users.new(user.first)   
  end
  
  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM users
      WHERE id = ?
      SQL
      
      Users.new(user.first)
  end
    
  def insert
    raise "#{self} already in database" if self.id
    QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname)
      INSERT INTO
        users (fname, lname)
      VALUES
        (?, ?)
    SQL

    self.id = QuestionsDatabase.instance.last_insert_row_id
  end

  def authored_questions
    Question.find_by_author_id(self.id)
  end

  def authored_replies
    Reply.find_by_author_id(self.id)
  end

end

class Reply

    attr_reader :author_id, :question_id, :id

    def initialize(options)
    @id = options['id']
    @body = options['body']
    @parent_id= options['parent_id']
    @author_id = options['author_id']
    @question_id = options['question_id']
  end

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM replies
      WHERE id = ?
    SQL

    Reply.new(reply.first)
  end

  def self.find_by_author_id(author_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT * FROM replies
      WHERE author_id = ?
    SQL
  
    Reply.new(reply.first)
  end

  def self.find_by_question_id(question_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT * FROM replies
      WHERE question_id = ?
    SQL
  
    Reply.new(reply.first)
  end

  # def insert
  #   raise "#{self} already in database" if self.id
  #   QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname)
  #     INSERT INTO
  #       users (fname, lname)
  #     VALUES
  #       (?, ?)
  #   SQL

  #   self.id = QuestionsDatabase.instance.last_insert_row_id
  # end

  def author
    User.find_by_id(self.author_id)
  end

  def question
    Question.find_by_id(self.question_id)
  end

  def parent_reply
    Reply.find_by_id(self.parent_id)
  end

  def child_replies
    reply = QuestionsDatabase.instance.execute(<<-SQL, self.id)
      SELECT id FROM replies
      WHERE parent_id = ?
    SQL

    Reply.find_by_id(reply.first['id'])
  end
end

class QuestionsLikes
    def initialize(options)
    @id = options['id']
    @likes = options['likes']
    @question_id = options['question_id']
    @author_id = options['author_id']
  end

  def self.find_by_id(id)
    likes = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM likes
      WHERE id = ?
    SQL

    QuestionsLikes.new(likes.first)
  end
end

class QuestionFollows
  def initialize(options)
    @id = options['id']
    @questions = options['questions']
    @users = options['users']
  end

  def self.find_by_id(id)
    follows = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT * FROM question_follows
      WHERE id = ?
    SQL

    QuestionFollows.new(follows.first)
  end
end
