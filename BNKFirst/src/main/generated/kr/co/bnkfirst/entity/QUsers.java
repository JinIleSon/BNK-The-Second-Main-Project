package kr.co.bnkfirst.entity;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;


/**
 * QUsers is a Querydsl query type for Users
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QUsers extends EntityPathBase<Users> {

    private static final long serialVersionUID = -65668833L;

    public static final QUsers users = new QUsers("users");

    public final DateTimePath<java.time.LocalDateTime> maccess = createDateTime("maccess", java.time.LocalDateTime.class);

    public final StringPath maddress = createString("maddress");

    public final DatePath<java.time.LocalDate> mbirth = createDate("mbirth", java.time.LocalDate.class);

    public final StringPath mcarrier = createString("mcarrier");

    public final StringPath mci = createString("mci");

    public final StringPath mcond = createString("mcond");

    public final DateTimePath<java.time.LocalDateTime> mdate = createDateTime("mdate", java.time.LocalDateTime.class);

    public final StringPath memail = createString("memail");

    public final StringPath mgender = createString("mgender");

    public final StringPath mgrade = createString("mgrade");

    public final StringPath mid = createString("mid");

    public final StringPath mjumin = createString("mjumin");

    public final StringPath mlimit = createString("mlimit");

    public final StringPath mname = createString("mname");

    public final StringPath mnum = createString("mnum");

    public final StringPath mphone = createString("mphone");

    public final StringPath mpw = createString("mpw");

    public final StringPath role = createString("role");

    public final NumberPath<Integer> uid = createNumber("uid", Integer.class);

    public QUsers(String variable) {
        super(Users.class, forVariable(variable));
    }

    public QUsers(Path<? extends Users> path) {
        super(path.getType(), path.getMetadata());
    }

    public QUsers(PathMetadata metadata) {
        super(Users.class, metadata);
    }

}

