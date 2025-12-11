package kr.co.bnkfirst.entity.product;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;


/**
 * QFund is a Querydsl query type for Fund
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QFund extends EntityPathBase<Fund> {

    private static final long serialVersionUID = -2104252051L;

    public static final QFund fund = new QFund("fund");

    public final NumberPath<Float> facmpr = createNumber("facmpr", Float.class);

    public final StringPath famc = createString("famc");

    public final StringPath fid = createString("fid");

    public final NumberPath<Float> fm12pr = createNumber("fm12pr", Float.class);

    public final NumberPath<Float> fm1pr = createNumber("fm1pr", Float.class);

    public final NumberPath<Float> fm3pr = createNumber("fm3pr", Float.class);

    public final NumberPath<Float> fm6pr = createNumber("fm6pr", Float.class);

    public final StringPath fname = createString("fname");

    public final NumberPath<Float> frefpr = createNumber("frefpr", Float.class);

    public final NumberPath<Integer> frlvl = createNumber("frlvl", Integer.class);

    public final StringPath fsetdt = createString("fsetdt");

    public final NumberPath<Float> ftc = createNumber("ftc", Float.class);

    public final StringPath ftype = createString("ftype");

    public QFund(String variable) {
        super(Fund.class, forVariable(variable));
    }

    public QFund(Path<? extends Fund> path) {
        super(path.getType(), path.getMetadata());
    }

    public QFund(PathMetadata metadata) {
        super(Fund.class, metadata);
    }

}

