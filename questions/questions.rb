require 'sqlite3'
require 'singleton'
# require 'byebug'

class QuestionsDatabase < SQLite3::Database
    include Singleton

    def initialize
        super('questions.db')
        self.type_translation = true
        self.results_as_hash = true
    end
end


class Question
    attr_accessor :id, :title, :body, :author_id

    def self.find_by_id(id)
        questions = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
                *
            FROM
                questions
            WHERE
                id = ?

        SQL

        return nil unless questions.length > 0
        Question.new(questions.first)

    end

    def self.find_by_author_id(author_id)
        questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
            SELECT
                *
            FROM
                questions
            WHERE
                author_id = ?

        SQL

        return nil unless questions.length > 0
        questions.map {|question| Question.new(question)}
        # Question.new(questions.first)
    end

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @author_id = options['author_id']
    end


    def author
        authors = QuestionsDatabase.instance.execute(<<-SQL, author_id)
        SELECT 
            *
        FROM 
            users
        WHERE
            id = ?
        SQL
        return nil unless authors.length > 0 
        Question.new(authors.first)
    end

    def replies

    end
end



class User
    attr_accessor :id, :fname, :lname

    def self.find_by_name(fname, lname)
        users = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
            SELECT
                *
            FROM
                users
            WHERE
                fname = ? AND lname = ?

        SQL

        return nil unless users.length > 0
        User.new(users.first)
    end

    def initialize(options)
        @id = options['id']
        @fname = options['fname']
        @lname = options['lname']
    end

    def authored_questions
        Question.find_by_author_id(self.id)
    end


    def authored_replies
        Reply.find_by_user_id(self.id)
    end

    def followed_questions
        # QuestionFollow.user_id
    end

end


class Reply
    attr_accessor :id, :parent_reply_id, :author_id, :question_id, :body

    def self.find_by_user_id(author_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, author_id)
            SELECT
                *
            FROM
                replies
            WHERE
                author_id = ?

        SQL

        return nil unless replies.length > 0
        replies.map {|reply| Reply.new(reply) }
    end

    def self.find_by_question_id(question_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                * 
            FROM 
                questions
            WHERE 
                id = ?
        SQL
        return nil unless replies.length > 0
        replies.map {|reply| Reply.new(reply) }
    end

    def initialize(options)
        @id = options['id']
        @parent_reply_id = options['parent_reply_id']
        @author_id = options['author_id']
        @question_id = options['question_id']
        @body = options['body']
    end

    def question
        replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT 
                * 
            FROM 
                questions
            WHERE
                id = ?
        SQL

        return nil unless replies.length > 0
        replies.map { |reply| Reply.new(reply) }
    end

    def parent_reply
        reply = QuestionsDatabase.instance.execute(<<-SQL, @id)
            SELECT
                *
            FROM
                replies
            WHERE
                replies.id = (
                    SELECT
                        parent_reply_id
                    FROM 
                        replies
                    WHERE
                        id = ?
                )

        SQL

        return nil unless reply.length > 0
        Reply.new(reply.first)

    end


    def child_replies
        replies = QuestionsDatabase.instance.execute(<<-SQL, self.id)
            SELECT
                *
            FROM
                replies
            WHERE
                parent_id = ?

        SQL

        return nil unless replies.length > 0
        replies.map {|reply| Reply.new(reply)}

    end
end




class QuestionFollow

    def self.followers_for_question_id(question_id)
        followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                users
            JOIN
                question_follows ON question_follows.user_id = users.id
            JOIN
                questions ON question_follows.question_id = questions.id
            WHERE
                question_follows.question_id = ?
        SQL

        return nil unless followers.length > 0
        followers.map {|follower| QuestionFollow.new(follower)}
    end

    def self.followed_questions_for_user_id(user_id)
        followers = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
                *
            FROM
                questions
            JOIN
                question_follows ON question_follows.question_id = questions.id
            JOIN
                users ON question_follows.user_id = users.id
            WHERE
                question_follows.user_id = ?
        SQL

        return nil unless followers.length > 0
        followers.map {|follower| QuestionFollow.new(follower)}
    end


end
