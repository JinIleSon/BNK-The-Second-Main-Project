package kr.co.bnkfirst.entity.product;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;


/**
 * QSlfcert is a Querydsl query type for Slfcert
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QSlfcert extends EntityPathBase<Slfcert> {

    private static final long serialVersionUID = -42532567L;

    public static final QSlfcert slfcert = new QSlfcert("slfcert");

    public final StringPath addr1 = createString("addr1");

    public final StringPath addr2 = createString("addr2");

    public final DatePath<java.time.LocalDate> brthdt = createDate("brthdt", java.time.LocalDate.class);

    public final DateTimePath<java.time.LocalDateTime> crtdt = createDateTime("crtdt", java.time.LocalDateTime.class);

    public final StringPath cusid = createString("cusid");

    public final StringPath enfnm = createString("enfnm");

    public final StringPath enlnm = createString("enlnm");

    public final DatePath<java.time.LocalDate> expdt = createDate("expdt", java.time.LocalDate.class);

    public final StringPath ftype = createString("ftype");

    public final StringPath gender = createString("gender");

    public final NumberPath<Integer> id = createNumber("id", Integer.class);

    public final StringPath krres = createString("krres");

    public final StringPath name = createString("name");

    public final StringPath natcd = createString("natcd");

    public final StringPath others = createString("others");

    public final StringPath phone = createString("phone");

    public final DatePath<java.time.LocalDate> signdt = createDate("signdt", java.time.LocalDate.class);

    public final StringPath sts = createString("sts");

    public final NumberPath<Integer> taxyr = createNumber("taxyr", Integer.class);

    public final DateTimePath<java.time.LocalDateTime> uptdt = createDateTime("uptdt", java.time.LocalDateTime.class);

    public final StringPath zipcd = createString("zipcd");

    public QSlfcert(String variable) {
        super(Slfcert.class, forVariable(variable));
    }

    public QSlfcert(Path<? extends Slfcert> path) {
        super(path.getType(), path.getMetadata());
    }

    public QSlfcert(PathMetadata metadata) {
        super(Slfcert.class, metadata);
    }

}

